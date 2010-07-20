require 'timeout'
require 'mocha'

module PM
  module Recaptcha
    PrivateKey = 'The-Private-Key-Scrubbed-For-The-Release'
    PublicKey  = '6Lfap7oSAAAAAEjp-cj0Sy0Qsh0AoRpCncCzwwpw'
    ReqTimeout = 5

    def self.enabled?
      Rails.env.production?
    end

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
            Timeout.timeout(ReqTimeout) do
              uri = URI.parse("http://api-verify.recaptcha.net/verify")
              Net::HTTP.post_form(uri,
                :privatekey => PrivateKey,
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

        label_text = options.delete(:label) || 'Enter the following words'

        recaptcha_options =
          options.empty? ? '' :
          javascript_tag(%[var RecaptchaOptions = #{options.to_json}])

        label_tag('recaptcha_response_field', label_text) + recaptcha_options +
        %[<script type="text/javascript"
             src="https://api-secure.recaptcha.net/challenge?k=#{PublicKey}">
          </script>

          <noscript>
             <iframe src="https://api-secure.recaptcha.net/noscript?k=#{PublicKey}"
                 height="320" width="420" frameborder="0"></iframe><br>
             <input type="text" class="text" name="recaptcha_challenge_field" tabindex="#{options[:tabindex]}"/>
             <input type="hidden" name="recaptcha_response_field" value="manual_challenge" />
          </noscript>
        ].html_safe
      end
    end

    module TestHelpers
      def mock_valid_captcha_on(object)
        object.stubs(:valid_captcha?).returns(true)
      end

      def mock_invalid_captcha_on(object)
        object.stubs(:valid_captcha?).returns(false)
      end
    end

  end
end

ActionView::Base.send :include, PM::Recaptcha::Helpers
ActionController::Base.send :include, PM::Recaptcha::Controller
