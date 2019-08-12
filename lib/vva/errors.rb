module VVA
  class ClientError < StandardError
    def initialize(msg = nil)
      super(msg)
    end

    def ignorable?
      false
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
end
