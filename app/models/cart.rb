class Cart < ApplicationRecord
  has_many :cart_items

  validates :shopify_id, uniqueness: true
end
