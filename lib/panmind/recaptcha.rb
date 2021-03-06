require 'timeout'

if defined?(Rails)
  require 'panmind/recaptcha/railtie'

  begin
    require 'mocha'
  rescue LoadError
    print "\n!!\n!! ReCaptcha: to use the test helpers you should gem install mocha\n!!\n\n"
  end if Rails.env.test?
end

module Panmind
  module Recaptcha
    Version = '1.0.2'

    class << self
      attr_accessor :private_key, :public_key, :request_timeout

      def set(options)
        self.private_key, self.public_key =
          options.values_at(:private_key, :public_key)

        # Defaults
        #
        self.request_timeout = options[:timeout] || 5
      end

      def enabled?
        Rails.env.production? || Rails.env.development?
      end
    end # << self

    class ConfigurationError < StandardError; end

    module Controller
      def self.included(base)
        base.instance_eval do
          def require_valid_captcha(options = {})
            if options.delete(:ajax)
              options.update(:unless => :captcha_already_solved?)
            end

            before_filter :validate_recaptcha, options
          end
        end
      end

      protected
        def validate_recaptcha
          invalid_captcha unless valid_captcha?
        end

        def captcha_already_solved?
          flash[:skip_captcha_check]
        end

        def save_solved_captcha
          flash[:skip_captcha_check] = true
        end

      private
        def valid_captcha?
          return true unless Recaptcha.enabled?

          challenge, response = params.values_at(
            :recaptcha_challenge_field, :recaptcha_response_field)

          return false if challenge.blank? || response.blank?

          req = 
            Timeout.timeout(Recaptcha.request_timeout) do
              uri = URI.parse("http://www.google.com/recaptcha/api/verify")
              Net::HTTP.post_form(uri,
                :privatekey => Recaptcha.private_key,
                :remoteip   => request.remote_ip,
                :challenge  => challenge,
                :response   => response
              )
            end

          res = req.body.split("\n")
          return res.first == 'true'

        rescue Timeout::Error
          # If ever a timeout error happens during the connection with 
          # the service, then return false. It should happen rarely.
          false
        end

        def invalid_captcha
          raise NotImplementedError, 'You must implement invalid_captcha in your controller'
        end
    end # Controller
  
    module Helpers
      def recaptcha(options = {})
        return unless Recaptcha.enabled?

        if Recaptcha.private_key.blank? || Recaptcha.public_key.blank?
          raise ConfigurationError, 'ReCaptcha keys are missing'
        end

        label_text = options.delete(:label) || 'Enter the following words'

        noscript_options = {:width => 420, :height => 320}.merge(
          options.delete(:noscript) || {})

        recaptcha_options =
          options.empty? ? '' :
          javascript_tag(%[var RecaptchaOptions = #{options.to_json}])

        label_tag('recaptcha_response_field', label_text) + recaptcha_options +
        %[<script type="text/javascript"
             src="http://www.google.com/recaptcha/api/challenge?k=#{Recaptcha.public_key}">
          </script>

          <noscript>
             <iframe src="http://www.google.com/recaptcha/api/noscript?k=#{Recaptcha.public_key}"
                 height="#{noscript_options[:width]}" width="#{noscript_options[:height]}" frameborder="0"></iframe><br>
             <input type="text" class="text" name="recaptcha_challenge_field" tabindex="#{options[:tabindex]}"/>
             <input type="hidden" name="recaptcha_response_field" value="manual_challenge" />
          </noscript>
        ].html_safe
      end
    end # Helpers

    module TestHelpers
      def mock_valid_captcha
        @controller.stubs(:valid_captcha?).returns(true)
      end

      def mock_invalid_captcha
        @controller.stubs(:valid_captcha?).returns(false)
      end
    end # TestHelpers

  end # Recaptcha
end # Panmind
