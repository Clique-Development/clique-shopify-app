module ShopifyApp
  class WebhooksController < ActionController::Base
    # include ShopifyApp::WebhookVerification
    protect_from_forgery with: :null_session
    skip_before_action :verify_authenticity_token

    class ShopifyApp::MissingWebhookJobError < StandardError; end

    def receive
      webhook_job_klass.perform_now(topic: webhook_type, shop_domain: shop_domain, webhook: params)
      head :no_content
    end

    private

    def webhook_params
      params.except(:controller, :action, :type)
    end

    def webhook_job_klass
      webhook_job_klass_name.safe_constantize or raise ShopifyApp::MissingWebhookJobError
    end

    def webhook_job_klass_name(type = webhook_type)
      ["#{type}_job"].compact.join('/').classify
    end

    def webhook_type
      params[:type]
    end

    def webhook_namespace
      ShopifyApp.configuration.webhook_jobs_namespace
    end

    def shop_domain
      request.headers["HTTP_X_SHOPIFY_SHOP_DOMAIN"]
    end
  end
end
