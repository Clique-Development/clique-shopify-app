require 'httparty'
require 'base64'
require 'builder'

class RewixOrderApiService
  include HTTParty
  base_uri 'https://griffati.rewix.zero11.org/restful'

  def initialize(api_key, password)
    @api_key = api_key
    @password = password

    @headers = {
      'Accept' => 'application/xml',
      'Content-Type' => 'application/xml',
      'Authorization' => "Basic " + Base64.strict_encode64("#{@api_key}:#{@password}")
    }
  end

  def create_dropshipping_order(order_data)
    xml_body = build_xml_order(order_data)

    response = self.class.post(
      '/ghost/orders/0/dropshipping',
      headers: @headers,
      body: xml_body
    )

    if response.success?
      puts "Order created successfully: #{response.body}"
    else
      raise "Failed to create order: #{response.message}"
    end
  end

  private

  # Build the XML for the order
  def build_xml_order(order_data)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :encoding => 'UTF-8', :standalone => 'yes'
    xml.root do
      xml.order_list do
        xml.order do
          xml.key order_data[:key]
          xml.date order_data[:date]
          xml.carrierId order_data[:carrierId] if order_data[:carrierId].present?

          xml.recipient_details do
            xml.recipient order_data[:recipient]
            xml.careof order_data[:careof]
            xml.cfpiva order_data[:cfpiva]
            xml.customer_key order_data[:customer_key]
            xml.notes order_data[:notes]
            xml.address do
              xml.street_type order_data[:street_type]
              xml.street_name order_data[:street_name]
              xml.address_number order_data[:address_number]
              xml.zip order_data[:zip]
              xml.city order_data[:city]
              xml.province order_data[:province]
              xml.countrycode order_data[:countrycode]
            end
            xml.phone do
              xml.prefix order_data[:prefix]
              xml.number order_data[:number]
            end
          end

          xml.item_list do
            xml.item do
              xml.stock_id order_data[:stock_id]
              xml.quantity order_data[:quantity]
            end
          end

          xml.autoConfirm order_data[:autoConfirm] ? 'true' : 'false'
        end
      end
    end
    xml.target!
  end
end
