require 'singleton'

class FetchPublicationId
  include Singleton

  def initialize
    @api_result = nil
  end

  def fetch_data(shop_domain, access_token)
    @api_result ||= fetch_from_api(shop_domain, access_token)
  end

  private

  def fetch_from_api(shop_domain, access_token)
    @session = ShopifyAPI::Auth::Session.new(
      shop: shop_domain,
      access_token: access_token
    )
    @client = ShopifyAPI::Clients::Graphql::Admin.new(
      session: @session
    )

    query = <<-'GRAPHQL'
  query {
    publications(first: 5) {
      edges {
        node {
          id
          name
        }
      }
    }
  }
    GRAPHQL

    response = @client.query(query: query)
    node = response.body['data']['publications']['edges'].find do |a|
      a['node']['name'] == 'Online Store'
    end
    node['node']['id']
  end
end