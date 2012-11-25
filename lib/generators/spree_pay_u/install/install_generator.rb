require 'rails/generators/migration'

module SpreePayU
 module Generators
  class InstallGenerator < ::Rails::Generators::Base

	desc "add migrations"

        def copy_migrations
	  rake 'spree_pay_u:install:migrations'
	end

  end
 end
end
