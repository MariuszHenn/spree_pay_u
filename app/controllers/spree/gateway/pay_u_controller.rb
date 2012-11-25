require 'digest/md5'
module Spree
  class Gateway::PayUController < Spree::BaseController
    skip_before_filter :verify_authenticity_token, :only => [:comeback, :complete ]
  
    # Show form Dotpay for pay
    def show
      #@payu_session_id = request.session_options[:id]
      @payu_session_id = Time.now.to_i.to_s
      @order = Order.find(params[:order_id])
      @client_ip = @order.ip_address
      @gateway = @order.available_payment_methods.find{|x| x.id == params[:gateway_id].to_i }
      @order.payments.destroy_all
      payment = @order.payments.create!(:amount => 0, :payment_method_id => @gateway.id, :sid => @payu_session_id)
      @total = (@order.total*100).to_i.to_s
      if @order.blank? || @gateway.blank?
        flash[:error] = I18n.t("invalid_arguments")
        redirect_to :back
      else
        @bill_address, @ship_address = @order.bill_address, (@order.ship_address || @order.bill_address)
      end
    end
    
    def error
      @errormsg = I18n.t("error"+params[:error])
    end
    
    # redirecting from PayU
    def complete
      @order = Order.find(params[:order_id])
      session[:order_id]=nil
      if @order.state=="complete" 
        redirect_to order_url(@order,{:checkout_complete => true, :order_token =>@order.token}), :notice => I18n.t("payment_success")
      else
        redirect_to order_url(@order)
      end
    end

    # Result from Dotpay
    def comeback
      @order = Order.find(params[:order_id])
      @gateway = @order && @order.payments.first.payment_method
      body = get_data(@gateway, @order)
      if validate_response(body,@gateway)
        t_status = get_value(body, "trans_status")
        if t_status.to_i == 99
          @order.payment.started_processing
	  if @order.total.to_f == get_value(body,"trans_amount").to_f/100
            @order.payment.complete
	  end
          @order.finalize!
	  @order.next
	  @order.next
	  @order.save    
	  redirect_to gateway_pay_u_complete_path(:order_id => @order.id, :gateway_id => @gateway.id)
          success = true #payment complete  
        else 
          success = false # 
          redirect_to gateway_pay_u_error_path(:error =>"status"+t_status, :pid => "0") and return 
        end
      else
        redirect_to gateway_pay_u_error_path(:error =>"_response_missmatch", :pid => "0") and return 
      end
   
      @body = validate_response(body,@gateway)
    end    


    private
    def get_value(body, string)
     return body.split(string)[1].split("\r\n")[0].split(": ")[1].to_s
    end

    # validating dotpay message
    def get_data(gateway, order)
      require 'net/https'
      require 'net/http'
      require 'open-uri'
      require 'openssl'
      sid = order.payments.first.sid
      ts = Time.now.to_f.to_s
      sig = Digest::MD5.hexdigest(gateway.preferred_pos_id+""+sid+""+ts+""+gateway.preferred_key1)
      params_new = {:pos_id => gateway.preferred_pos_id, :session_id => sid, :ts => ts, :sig => sig}
      url = URI.parse(gateway.get_url)
      req = Net::HTTP::Post.new(url.path,{"User-Agent" => "Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.10) Gecko/20100915 Ubuntu/10.04 (lucid) Firefox/3.6.10"})
      req.form_data = params_new
      #req.basic_auth url.user, url.password if url.user
      con = Net::HTTP.new(url.host, 443)
      con.use_ssl = true
      con.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = con.start {|http| http.request(req)}
      return response.body
    end
    
    def validate_response(body, gateway)
      ##pos_id + sessiion_id + order_id + status + amount + desc + ts + key2
      pid = get_value(body, "trans_pos_id")
      sid = get_value(body, "trans_session_id")
      oid = get_value(body, "trans_order_id")
      sta = get_value(body, "trans_status")
      amo = get_value(body, "trans_amount")
      des = get_value(body, "trans_desc")
      ts = get_value(body, "trans_ts")
      sig = get_value(body, "trans_sig")
      key2 = gateway.preferred_key2
      mysig = Digest::MD5.hexdigest(pid+""+sid+""+oid+""+sta+""+amo+""+des+""+ts+""+key2)
      return mysig == sig
    end

    # Completed payment process
    def dotpay_pl_payment_success(params)
      @order.payment.started_processing
      if @order.total.to_f == params[:amount].to_f
        @order.payment.complete
      end

      @order.next
    end

    # payment cancelled by user (dotpay signals 3 to 5)
    def dotpay_pl_payment_cancel(params)
      @order.cancel
    end

    def dotpay_pl_payment_new(params)
      @order.payment.started_processing
      @order.finalize!
    end

  end
end

