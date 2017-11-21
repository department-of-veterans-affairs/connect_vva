# frozen_string_literal: true
require "savon"
require "nokogiri"
require "httpi/net_http/cipher"

module VVA

  class ClientError < StandardError
  end

  class HTTPError < ClientError
    attr_reader :code, :body, :data

    def initialize(code:, body:, data:)
      super("status_code=#{code}, body=#{body}, data=#{data}")
      @code = code
      @body = body
      @data = data
    end
  end

  class SOAPError < ClientError
    def initialize(msg)
      super(msg)
    end
  end

  class Base
    def initialize(wsdl: nil, username: nil, password: nil,
                   ssl_cert_file: nil, ssl_cert_key_file: nil, ssl_ca_cert: nil,
                   forward_proxy_url: nil, log: false)
      @wsdl = wsdl
      @username = username
      @password = password
      @ssl_cert_file = ssl_cert_file
      @ssl_cert_key_file = ssl_cert_key_file
      @ssl_ca_cert = ssl_ca_cert
      @forward_proxy_url = forward_proxy_url
      @log = log
    end

    HTTPI::Adapter::NetHTTP.prepend HTTPI::NetHTTP::Cipher

    private

    def header
      # Stock XML structure {{{
      header = Nokogiri::XML::DocumentFragment.parse <<-EOXML
  <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
    <wsse:UsernameToken>
      <wsse:Username></wsse:Username>
      <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText"></wsse:Password>
    </wsse:UsernameToken>
  </wsse:Security>
  EOXML
      # }}}

      { Username: @username, Password: @password }.each do |k, v|
        header.xpath(".//*[local-name()='#{k}']")[0].content = v
      end
      header
    end

    def domain
      @wsdl.match(/\/([a-zA-z0-9\.\-]+?):/).captures[0]
    end

    def wsdl
      if @forward_proxy_url
        return @wsdl.gsub(/https:\/\/([a-zA-z0-9\.:\-]+?)\//, @forward_proxy_url+"/")
      end
      @wsdl
    end

    def namespaces
      {
        "xmlns:wsu" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
      }
    end

    def client
      @client ||= Savon.client(
        wsdl: wsdl,
        soap_header: header,
        namespaces: namespaces,
        log: @log,
        ssl_cert_key_file: @ssl_cert_key_file,
        ssl_cert_file: @ssl_cert_file,
        ssl_ca_cert_file: @ssl_ca_cert,
        ssl_verify_mode: :none,
        pretty_print_xml: true,
        adapter: :net_http
      )
    end

    # Proxy to call a method on our web service.
    def request(method, message)
      tries ||= 3
      client.wsdl.request.headers = { "Host" => domain } if @forward_proxy_url
      client.call(method, message: message)
    # We are going to retry 3 times if there is an SSL error
    rescue HTTPI::SSLError => e
      sleep 1 and retry unless (tries -= 1).zero?
      raise e
    rescue Savon::SOAPFault => e
      raise VVA::SOAPError.new(e)
    end
  end
end
