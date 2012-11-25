class AddSidToPayments < ActiveRecord::Migration
  def self.up
  add_column :spree_payments, :sid, :string
  end
end
