module VVA

  class DocumentContentWebService < VVA::Base

    def self.service_name
      "document_content"
    end

    def get_by_document_id(document_id:, source:, format:, jro:, ssn:)
      # these are all required fields
      response = request(
        :get_document_content,
        "fnDcmntId": document_id,
        "fnDcmntSource": source,
        "dcmntFormatCd": format,
        "jro": jro,
        "userId": ssn
      )
      content = response.body[:get_document_content_response][:content]
      mime_type = response.body[:get_document_content_response][:mime_type]
      OpenStruct.new(content: Base64.decode64(content), mime_type: mime_type)
    end
  end
end
