require 'timeout'

module PM
  module Recaptcha
    PrivateKey = 'The-Private-Key-Scrubbed-For-The-Release'
    PublicKey  = '6Lfap7oSAAAAAEjp-cj0Sy0Qsh0AoRpCncCzwwpw'
    ReqTimeout = 5

    module Controller
      protected
        def validate_recaptcha
          invalid_captcha unless valid_captcha?
        end

      private
        def valid_captcha?
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
                 height="200" width="420" frameborder="0"></iframe><br>
             <textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
             <input type="hidden" name="recaptcha_response_field" value="manual_challenge">
          </noscript>
        ]
      end
    end
  end
end

ActionView::Base.send :include, PM::Recaptcha::Helpers
ActionController::Base.send :include, PM::Recaptcha::Controller
