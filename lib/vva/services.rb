require "vva/services/document_list"
require "vva/services/document_content"

# Class to hide the actual creation of service objects, since having
# to construct them all really sucks.
module VVA
  class Services
    def initialize(wsdl: nil, username: nil, password: nil,
                   ssl_cert_file: nil, ssl_cert_key_file: nil, ssl_ca_cert: nil,
                   forward_proxy_url: nil, log: false)

      @config = { wsdl: wsdl, username: username, password: password,
                  ssl_cert_file: ssl_cert_file,
                  ssl_cert_key_file: ssl_cert_key_file,
                  ssl_ca_cert: ssl_ca_cert,
                  forward_proxy_url: forward_proxy_url,
                  log: log }
    end

    def self.all
      ObjectSpace.each_object(Class).select { |klass| klass < VVA::Base }
    end

    VVA::Services.all.each do |service|
      define_method(service.service_name) do
        service.new @config
      end
    end
  end
end
