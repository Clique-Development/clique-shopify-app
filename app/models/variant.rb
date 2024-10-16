class Variant < ApplicationRecord
  has_many :attachments, as: :imageable, dependent: :destroy
  has_many :line_items, -> { where('line_items.created_at >= ?', 30.days.ago) }, foreign_key: :shopify_variant_id, primary_key: :shopify_variant_id

  belongs_to :product
  has_one :shop, through: :product
end
