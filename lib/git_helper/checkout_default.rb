# frozen_string_literal: true

module GitHelper
  class CheckoutDefault
    def execute
      GitHelper::LocalCode.new.checkout_default
    end
  end
end
