# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_11_07_093029) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.bigint "shopify_addr_id"
    t.bigint "shopify_customer_id"
    t.string "first_name"
    t.string "last_name"
    t.string "company"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "province"
    t.string "country"
    t.string "zip"
    t.string "phone"
    t.string "name"
    t.string "province_code"
    t.string "country_code"
    t.string "country_name"
    t.string "address_type"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.boolean "is_deleted", default: false
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_addresses_on_order_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "shopify_id"
    t.integer "quantity"
    t.string "sku"
    t.bigint "variant_id"
    t.bigint "cart_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
  end

  create_table "carts", force: :cascade do |t|
    t.string "shopify_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_weights", force: :cascade do |t|
    t.string "category"
    t.string "subcategory"
    t.float "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "shopify_customer_id"
    t.string "email"
    t.boolean "accepts_marketing"
    t.string "first_name"
    t.string "last_name"
    t.integer "orders_count"
    t.string "state"
    t.decimal "total_spent"
    t.integer "last_order_id"
    t.text "note"
    t.boolean "verified_email"
    t.string "multipass_identifier"
    t.boolean "tax_exempt"
    t.string "tags"
    t.string "last_order_name"
    t.string "currency"
    t.string "phone"
    t.boolean "is_deleted", default: false
    t.datetime "shopify_created_at"
    t.datetime "shopify_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "shop_id"
    t.index ["shop_id"], name: "index_customers_on_shop_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "shopify_id"
    t.string "name"
    t.string "title"
    t.decimal "price"
    t.bigint "shopify_product_id"
    t.integer "fulfillable_quantity"
    t.string "fulfillment_status"
    t.integer "quantity"
    t.string "sku"
    t.decimal "total_discount"
    t.bigint "variant_id"
    t.string "variant_title"
    t.string "vendor"
    t.boolean "requires_shipping"
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "product_id"
    t.bigint "shopify_variant_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "shopify_order_id"
    t.integer "order_number"
    t.string "name"
    t.string "email"
    t.string "order_status_url"
    t.string "cancel_reason"
    t.datetime "cancelled_at"
    t.string "cart_token"
    t.string "checkout_id"
    t.string "checkout_token"
    t.boolean "confirmed"
    t.string "currency"
    t.decimal "total_price"
    t.decimal "subtotal_price"
    t.decimal "current_total_tax"
    t.decimal "total_discounts"
    t.boolean "fulfillment_status"
    t.string "phone"
    t.string "tags"
    t.string "token"
    t.decimal "total_tax"
    t.datetime "shopify_created_at"
    t.string "note"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "shop_id"
    t.bigint "customer_id"
    t.string "financial_status"
    t.float "cost_of_dropshipping"
    t.bigint "rewix_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["shop_id"], name: "index_orders_on_shop_id"
    t.index ["shopify_order_id"], name: "index_orders_on_shopify_order_id", unique: true
  end

  create_table "price_settings", force: :cascade do |t|
    t.decimal "cost_of_kg"
    t.decimal "gross_margin"
    t.decimal "black_market_egp_markup"
    t.decimal "final_black_market_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.bigint "external_id"
    t.bigint "shopify_product_id"
    t.string "name"
    t.string "status"
    t.string "inventory"
    t.string "category_type"
    t.string "vendor"
    t.string "dropship_supplier"
    t.string "warehouse_location"
    t.string "subcategory"
    t.string "image_url"
    t.decimal "quantity"
    t.decimal "unit_cost_eur"
    t.decimal "cost_of_dropship_carrier_eur"
    t.decimal "unit_cost_usd"
    t.decimal "unit_cost_egp"
    t.decimal "cost_of_kg"
    t.decimal "cost_of_gram"
    t.decimal "unit_weight_gr"
    t.decimal "unit_cost_including_weight_usd"
    t.decimal "unit_cost_including_weight_egp"
    t.decimal "gross_margin"
    t.decimal "final_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "shop_id"
    t.decimal "actual_weight"
    t.index ["shop_id"], name: "index_products_on_shop_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "access_scopes", default: "", null: false
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "variants", force: :cascade do |t|
    t.bigint "shopify_variant_id"
    t.bigint "shopify_product_id"
    t.string "title"
    t.decimal "price"
    t.string "sku"
    t.integer "position"
    t.string "inventory_policy"
    t.decimal "compare_at_price"
    t.string "fulfillment_service"
    t.string "inventory_management"
    t.boolean "taxable", default: false
    t.string "barcode"
    t.integer "grams"
    t.bigint "image_id"
    t.decimal "weight"
    t.string "weight_unit"
    t.bigint "inventory_item_id"
    t.integer "inventory_quantity"
    t.integer "old_inventory_quantity"
    t.boolean "requires_shipping", default: false
    t.string "admin_graphql_api_id"
    t.datetime "shopify_created_at"
    t.datetime "shopify_updated_at"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stock_id"
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

  add_foreign_key "orders", "customers"
end
