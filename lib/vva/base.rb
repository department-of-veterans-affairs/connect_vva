# frozen_string_literal: true
require "savon"
require "nokogiri"
require "httpi/net_http/cipher"

module VVA
  class ClientError < StandardError
    def initialize(msg = nil)
      super(msg)
    end
  end

  class HTTPError < ClientError
    attr_reader :code, :body

    def initialize(err)
      @code = err.to_hash[:code]
      @body = err.to_hash[:body]
      super("status_code=#{code}, body=#{body}")
    end
  end

  class SOAPError < ClientError
  end

  class SSLError < ClientError
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
      @wsdl.match(%r{/([a-zA-z0-9\.\-]+?):}).captures[0]
    end

    def namespaces
      {
        "xmlns:wsu" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
      }
    end

    def client
      @client ||= Savon.client(
        wsdl: @wsdl,
        open_timeout: 600,
        read_timeout: 600,
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
      # We're using Host and Path rewrites to route requests
      # through Envoy forward proxy; therefore we need to
      # change the `path` and `Host` headers
      if @forward_proxy_url
        client.wsdl.document = @wsdl.gsub(%r{https://([a-zA-z0-9\.:\-]+?)/}, @forward_proxy_url + "/envoy-prefix-#{method}/")
        client.wsdl.request.headers = { "Host" => domain }
      end
      client.call(method, message: message)
    rescue Savon::SOAPFault => e
      raise VVA::SOAPError.new(e)
    rescue Savon::HTTPError => e
      raise VVA::HTTPError.new(e)
    rescue HTTPI::SSLError => e
      raise VVA::SSLError.new(e)
    end
  end
end
