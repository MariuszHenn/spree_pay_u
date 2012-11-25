class AddSidToPayments < ActiveRecord::Migration
  def change
  add_column :spree_payments, :sid, :string
  end
end
