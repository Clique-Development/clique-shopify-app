class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.string :shopify_id, unique: true, null: false

      t.timestamps
    end
  end
end
