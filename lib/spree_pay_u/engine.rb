module SpreePayU
  class Engine < Rails::Engine
    
    engine_name 'spree_pay_u'
    isolate_namespace SpreePayU

    config.autoload_paths += %W(#{config.root}/lib)
    
    initializer "spree.gateway.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::PayU
      app.class.configure do
        config.paths['db/migrate'] += SpreePayU::Engine.paths['db/migrate'].existent
      end
    end
    config.to_prepare do
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? reqire(c) : load(c)
      end
    end
  end
end
