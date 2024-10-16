class Product < ApplicationRecord
  belongs_to :shop
  has_many :variants, dependent: :destroy
  has_many :line_items
end
