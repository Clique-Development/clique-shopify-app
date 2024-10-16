class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.bigint :shopify_addr_id
      t.bigint :shopify_customer_id
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :address1
      t.string :address2
      t.string :city
      t.string :province
      t.string :country
      t.string :zip
      t.string :phone
      t.string :name
      t.string :province_code
      t.string :country_code
      t.string :country_name
      t.string :address_type
      t.decimal  :latitude, precision: 10, scale: 7
      t.decimal  :longitude, precision: 10, scale: 7
      t.boolean :is_deleted, default: false
      t.references :order

      t.timestamps
    end
  end
end