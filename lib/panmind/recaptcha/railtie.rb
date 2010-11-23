require 'panmind/recaptcha'

module Panmind
  module Recaptcha

    if defined? Rails::Railtie
      class Railtie < Rails::Railtie
        initializer 'panmind.recaptcha.insert_into_action_controller' do
          ActiveSupport.on_load :action_controller do
            Panmind::Recaptcha::Railtie.insert
          end
        end
      end
    end

    class Railtie
      def self.insert
        debugger
        ActionView::Base.instance_eval { include Helpers }
        ActionController::Base.instance_eval { include Controller }
        ActionController::TestCase.instance_eval { include TestHelpers } if Rails.env.test?
      end
    end

  end
end
