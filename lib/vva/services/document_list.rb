module VVA

  class DocumentListWebService < VVA::Base

    def get_by_claim_number(claim_number)
      response = request(:get_document_list, "claimNbr": claim_number)
      response.body[:get_document_list_response][:dcmnt_record_collection]
    end

    def get_by_ssn(ssn)
      # TODO
    end

  end
end
