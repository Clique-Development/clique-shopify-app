class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true
  belongs_to :variant, optional: true
end
