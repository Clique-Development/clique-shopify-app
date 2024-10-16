class Address < ApplicationRecord
  belongs_to :order, optional: true
end
