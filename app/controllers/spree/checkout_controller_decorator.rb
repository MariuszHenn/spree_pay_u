module Spree
  CheckoutController.class_eval do

    before_filter :redirect_for_payu, :only => :update

    private

    def redirect_for_payu
      return unless params[:state] == "payment"
      @payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      if @payment_method && @payment_method.kind_of?(PaymentMethod::PayU)
        redirect_to gateway_pay_u_path(:gateway_id => @payment_method.id, :order_id => @order.id)
      end
    end

  end
end
