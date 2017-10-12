module HTTPI
  module NetHTTP
    module Cipher

      private

      # Savon uses the HTTPi library for the network requests but this library
      # does not support setting SSL ciphers
      # The following patch redefines net_http setup_ssl_auth to explicitly
      # deny the DH ciphers in the list of allowed SSL ciphers
      def setup_ssl_auth
        super
        @client.ciphers = ["DEFAULT:!DH"]
      end
    end
  end
end
