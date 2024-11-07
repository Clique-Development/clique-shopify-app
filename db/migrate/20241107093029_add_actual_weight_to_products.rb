class AddActualWeightToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :actual_weight, :decimal
  end
end
