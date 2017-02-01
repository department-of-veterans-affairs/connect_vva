# frozen_string_literal: true
require "savon"
require "nokogiri"

module VVA
  class Base
    def initialize(wsdl:, username:, password:, log: false,
                   ssl_cert_file: nil, ssl_cert_key_file: nil, ssl_ca_cert: nil)
      @wsdl = wsdl
      @username = username
      @password = password
      @ssl_cert_file = ssl_cert_file
      @ssl_cert_key_file = ssl_cert_key_file
      @ssl_ca_cert = ssl_ca_cert
      @log = log
    end

    private

    def header
      {
        "wsse:Security": {
          "wsse:UsernameToken": {
            "wsse:Username": @username,
            "wsse:Password": @password
          }
        }
      }
    end

    def namespaces
      {
        "xmlns:wsse" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd",
        "xmlns:wsu" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility- 1.0.xsd"
      }
    end

    def client
      @client ||= Savon.client(
        wsdl: @wsdl, soap_header: header, namespaces: namespaces, log: @log,
        ssl_cert_key_file: @ssl_cert_key_file,
        ssl_cert_file: @ssl_cert_file,
        ssl_ca_cert_file: @ssl_ca_cert
      )
    end

    # Proxy to call a method on our web service.
    def request(method, message)
      client.call(method, message: message)
    end
  end
end
