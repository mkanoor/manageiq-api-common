module ManageIQ
  module API
    module Common
      class Request
        FORWARDABLE_HEADER_KEYS = %w(X-Request-ID x-rh-identity).freeze

        def self.current
          Thread.current[:current_request]
        end

        def self.current=(request)
          Thread.current[:current_request] =
            case request
            when ActionDispatch::Request, Hash
              new(request)
            when nil
              request
            else
              raise ArgumentError, 'Not an ActionDispatch::Http::Headers Class or Hash, or nil'
            end
        end

        def self.with_request(request)
          saved = current
          self.current = request
          yield current
        ensure
          self.current = saved
        end

        def self.current_forwardable
          raise ManageIQ::API::Common::HeadersNotSet, "Current headers have not been set" unless current
          current.forwardable
        end

        attr_reader :headers, :original_url, :cookie_jar

        def initialize(request, **kwargs)
          request = request_from_hash(request) if request.kind_of?(Hash)
          @headers, @original_url, @cookie_jar = request.headers, request.original_url, request.cookie_jar
        end

        def user
          @user ||= User.new
        end

        def to_h
          {:headers => forwardable, :original_url => original_url}
        end

        def forwardable
          FORWARDABLE_HEADER_KEYS.each_with_object({}) do |key, hash|
            hash[key] = @headers[key] if @headers.key?(key)
          end
        end

        private

        def headers_from_hash(hash)
          hash.dup.transform_keys { |key| fix_key_name(key.to_s) }
        end

        def fix_key_name(key)
          return key if key.start_with?('HTTP_')
          "HTTP_#{key.tr('-', '_').upcase}"
        end

        def request_from_hash(hash)
          headers = hash[:headers].presence || {}
          ActionDispatch::TestRequest.new(headers_from_hash(headers))
        end
      end
    end
  end
end
