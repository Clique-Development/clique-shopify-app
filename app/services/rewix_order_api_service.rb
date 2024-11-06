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
      response['root']['order_id']
    else
      raise "Failed to create order: #{response.message}"
      nil
    end
  end

  private

  # Build the XML for the order
  def build_xml_order(order_data)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :encoding => 'UTF-8', :standalone => 'yes'
    xml.root do
      xml.order_list do
        order_data[:order_list].each do |order|
          xml.order do
            xml.key order[:key]
            xml.date order[:date]
            xml.carrierId order[:carrierId]

            xml.recipient_details do
              xml.recipient order[:recipient_details][:recipient]
              xml.cfpiva order[:recipient_details][:cfpiva]
              xml.customer_key order[:recipient_details][:customer_key]
              xml.careof
              xml.notes

              xml.address do
                xml.street_type order[:recipient_details][:address][:street_type]
                xml.street_name order[:recipient_details][:address][:street_name]
                xml.address_number order[:recipient_details][:address][:address_number]
                xml.zip order[:recipient_details][:address][:zip]
                xml.city order[:recipient_details][:address][:city]
                xml.province order[:recipient_details][:address][:province]
                xml.countrycode order[:recipient_details][:address][:countrycode]
              end

              xml.phone do
                xml.prefix order[:recipient_details][:phone][:prefix]
                xml.number order[:recipient_details][:phone][:number]
              end
            end

            xml.item_list do
              order[:item_list].each do |item|
                xml.item do
                  xml.stock_id item[:stock_id]
                  xml.quantity item[:quantity]
                end
              end
            end

            xml.autoConfirm order[:autoConfirm]
          end
        end
      end
    end
    xml.target!
  end
end
