Spree::Core::Engine.routes.append do
  namespace :gateway do
    match '/pay_u/:gateway_id/:order_id' => 'pay_u#show', :as => :pay_u
    match '/pay_u/comeback' => 'pay_u#comeback', :as => :pay_u_comeback
    match '/pay_u/complete' => 'pay_u#complete', :as => :pay_u_complete
    match '/pay_u/error/:error/:order_id' => 'pay_u#error', :as => :pay_u_error
  end
end
