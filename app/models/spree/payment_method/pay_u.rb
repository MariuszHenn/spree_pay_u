module Spree
  class PaymentMethod::PayU < PaymentMethod
    
    attr_accessible :preferred_pos_id, :preferred_pos_auth_key, :preferred_test_mode, :preferred_key1, :preferred_key2

    preference :test_mode, :boolean, :default => false
    preference :pos_id, :string
    preference :pos_auth_key, :string
    preference :key1, :string
    preference :key2, :string

    def payment_profiles_supported?
      false
    end
    
    def url
      if preferred_test_mode
        s = "sandbox."
      else
        s=""
      end
      "https://"+s+"payu.pl/paygw/UTF/"
    end
    
    def get_url
      url+"Payment/get"
    end  
    def post_url
      url+"NewPayment"
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
