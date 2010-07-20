require 'panmind/recaptcha'

module Panmind::Recaptcha
  ActionView::Base.instance_eval { include Helpers }
  ActionController::Base.instance_eval { include Controller }
  ActionController::TestCase.instance_eval { include TestHelpers } if Rails.env.test?
end
