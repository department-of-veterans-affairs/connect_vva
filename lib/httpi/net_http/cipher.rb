module HTTPI
  module NetHTTP
    module Cipher

      private

      def setup_ssl_auth
        super
        @client.ciphers = ["DEFAULT:!DH"]
      end
    end
  end
end
