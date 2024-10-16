class Order < ApplicationRecord
  has_many :line_items, dependent: :destroy
  has_many :addresses, dependent: :destroy

  has_one :shipping_address, -> { where(addresses: { address_type: 'shipping_address' }) }, class_name: 'Address'
  has_one :billing_address, -> { where(addresses: { address_type: 'billing_address' }) }, class_name: 'Address'

  belongs_to :customer, optional: true
  belongs_to :shop
end
