require 'timeout'

if Rails.env.test?
  begin
    require 'mocha'
  rescue LoadError
    print "\n!!\n!! ReCaptcha: to use the test helpers you should gem install mocha\n!!\n\n"
  end
end

module PM
  module Recaptcha
    attr_accessor :private_key, :public_key,
                  :request_timeout, :cache_expiration

    def self.set(options)
      self.private_key, self.public_key =
        options.values_at(:private_key, :public_key)

      # Defaults
      #
      self.request_timeout = options[:timeout] || 5
    end

    def self.enabled?
      Rails.env.production?
    end

    class ConfigurationError < StandardError; end

    class SolvedCaptcha
      def self.add(email, challenge)
        Rails.cache.write PM::Cache.namespaced_path(email, challenge), :expires_in => 5.minutes
      end

      def self.check(email, challenge)
        Rails.cache.exist? PM::Cache.namespaced_path(email, challenge)
      end
    end

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
          email = params[:user][:email] || params[:email]
          SolvedCaptcha.check(email, params[:recaptcha_challenge_field])
        end

        def save_solved_captcha
          SolvedCaptcha.add(params[:email], params[:recaptcha_challenge_field])
        end

      private
        def valid_captcha?
          return true unless PM::Recaptcha.enabled?

          challenge, response = params.values_at(
            :recaptcha_challenge_field, :recaptcha_response_field)

          return false if challenge.blank? || response.blank?

          req = 
            Timeout.timeout(Recaptcha.request_timeout) do
              uri = URI.parse("http://api-verify.recaptcha.net/verify")
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
          # Let it go...
          true
        end

        def invalid_captcha
          raise NotImplementedError, 'You must implement invalid_captcha in your controller'
        end
    end
  
    module Helpers
      def recaptcha(options = {})
        return unless PM::Recaptcha.enabled?

        if Recaptcha.private_key.blank? || Recaptcha.public_key.blank?
          raise ConfigurationError, 'ReCaptcha keys are missing'
        end

        label_text = options.delete(:label) || 'Enter the following words'

        recaptcha_options =
          options.empty? ? '' :
          javascript_tag(%[var RecaptchaOptions = #{options.to_json}])

        label_tag('recaptcha_response_field', label_text) + recaptcha_options +
        %[<script type="text/javascript"
             src="https://api-secure.recaptcha.net/challenge?k=#{Recaptcha.public_key}">
          </script>

          <noscript>
             <iframe src="https://api-secure.recaptcha.net/noscript?k=#{Recaptcha.public_key}"
                 height="320" width="420" frameborder="0"></iframe><br>
             <input type="text" class="text" name="recaptcha_challenge_field" tabindex="#{options[:tabindex]}"/>
             <input type="hidden" name="recaptcha_response_field" value="manual_challenge" />
          </noscript>
        ].html_safe
      end
    end

    module TestHelpers
      def mock_valid_captcha
        @controller.stubs(:valid_captcha?).returns(true)
      end

      def mock_invalid_captcha
        @controller.stubs(:valid_captcha?).returns(false)
      end
    end

  end
end

ActionView::Base.send :include, PM::Recaptcha::Helpers
ActionController::Base.send :include, PM::Recaptcha::Controller
ActionController::TestCase.send :include, PM::Recaptcha::TestHelpers if Rails.env.test?
