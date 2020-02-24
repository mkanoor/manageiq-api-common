module Insights
  module API
    module Common
      module RBAC
        require 'rbac-api-client'

        class Service
          def self.call(klass)
            setup
            yield init(klass)
          rescue RBACApiClient::ApiError => err
            Rails.logger.error("RBACApiClient::ApiError #{err.message} ")
            raise
          end

          def self.paginate(obj, method, pagination_options, *method_args)
            Enumerator.new do |enum|
              opts = { :limit => 10, :offset => 0 }.merge(pagination_options)
              count = nil
              fetched = 0
              begin
                loop do
                  args = [method_args, opts].flatten.compact
                  result = obj.send(method, *args)
                  count ||= result.meta.count
                  opts[:offset] = opts[:offset] + result.data.count
                  result.data.each do |element|
                    enum.yield element
                  end
                  fetched += result.data.count
                  break if count == fetched || result.data.empty?
                end
              rescue StandardError => e
                Rails.logger.error("Exception when calling pagination on #{method} #{e}")
                raise
              end
            end
          end

          private_class_method def self.setup
            RBACApiClient.configure do |config|
              config.host   = ENV['RBAC_URL'] || 'localhost'
              config.scheme = URI.parse(ENV['RBAC_URL']).try(:scheme) || 'http'
              config.debugging = true
              dev_credentials(config)
              api_key(config)
            end
          end

          private_class_method def self.init(klass)
            headers = Insights::API::Common::Request.current_forwardable
            Rails.logger.error("In class init #{headers.to_s}")
            klass.new.tap do |api|
              api.api_client.default_headers = api.api_client.default_headers.merge(headers)
              Rails.logger.error("Default Headers #{api.api_client.default_headers.to_s}")
            end
          end

          private_class_method def self.dev_credentials(config)
            # Set up user/pass for basic auth if we're in dev and they exist.
            if Rails.env.development?
              config.username = ENV.fetch('DEV_USERNAME')
              config.password = ENV.fetch('DEV_PASSWORD')
            end
          end

          private_class_method def self.api_key(config)
            config.api_key['x-rh-identity'] = Insights::API::Common::Request.current_forwardable['x-rh-identity']
          end
        end
      end
    end
  end
end
