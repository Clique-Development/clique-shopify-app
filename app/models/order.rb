class Order < ApplicationRecord
  has_many :line_items, dependent: :destroy
  has_many :addresses, dependent: :destroy

  has_one :shipping_address, -> { where(addresses: { address_type: 'shipping_address' }) }, class_name: 'Address'
  has_one :billing_address, -> { where(addresses: { address_type: 'billing_address' }) }, class_name: 'Address'

  belongs_to :customer, optional: true
  belongs_to :shop

  scope :paid, -> { where(financial_status: 'paid') }

  def self.paid_and_due_amounts
    session = Shop.last.retrieve_session
    paid_amount = 0
    total_amount = 0
    all.each do |order|
      transactions = ShopifyAPI::Transaction.all(order_id: order.shopify_order_id, session: session)
      paid_amount += transactions.sum { |transaction| transaction.amount.to_f if transaction.status == 'success' }
      total_amount += order.total_price
    end
    [paid_amount, total_amount - paid_amount]
  end
end
