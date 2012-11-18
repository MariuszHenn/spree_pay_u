module Spree
  class PaymentMethod::PayU < PaymentMethod
    
    attr_accessible :preferred_pos_id, :preferred_pos_auth_key, :preferred_test_mode, :preferred_url, :preferred_test_url

    preference :test_mode, :boolean, :default => false
    preference :pos_id, :string
    preference :pos_auth_key, :string
    preference :url, :string, :default => "https://www.platnosci.pl/paygw/UTF/NewPayment"
    preference :test_url, :string, :default => "https://sandbox.platnosci.pl/paygw/UTF/NewPayment"

    def payment_profiles_supported?
      false
    end
    
    def post_url
      if preferred_test_mode
        preferred_test_url
      else
        preferred_url
      end
    end

    def pay_type
      if preferred_test_mode
        "t"
      else
        ""
      end
    end

  end
end