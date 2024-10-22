class AddStockIdToVariants < ActiveRecord::Migration[7.0]
  def change
    add_column :variants, :stock_id, :string
  end
end