class AddCustomerToOrder < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :customer, foreign_key: true
    add_column :orders, :financial_status, :string
    add_column :orders, :cost_of_dropshipping, :float
  end
end
