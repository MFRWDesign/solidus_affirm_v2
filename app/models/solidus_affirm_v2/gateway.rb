# frozen_string_literal: true

require 'affirm'

module SolidusAffirmV2
  class Gateway
    def initialize(options)
      ::Affirm.configure do |config|
        config.public_api_key  = options[:public_api_key]
        config.private_api_key = options[:private_api_key]
        config.environment     = options[:test_mode] ? :sandbox : :production
      end
    end

    def authorize(_money, affirm_source, _options = {})
      begin
        response = ::Affirm::Client.new.authorize(affirm_source.transaction_id)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Approved", {}, authorization: response.id)
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end

    def capture(_money, transaction_id, _options = {})
      begin
        response = ::Affirm::Client.new.capture(transaction_id)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Captured")
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end

    def void(transaction_id, _money, _options = {})
      begin
        response = ::Affirm::Client.new.void(transaction_id)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Voided")
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end

    def credit(money, transaction_id, _options = {})
      begin
        response = ::Affirm::Client.new.refund(transaction_id, money)
        return ActiveMerchant::Billing::Response.new(true, "Transaction Credited with #{money}")
      rescue Exception => e
        return ActiveMerchant::Billing::Response.new(false, e.message)
      end
    end
  end
end
