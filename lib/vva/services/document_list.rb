module VVA

  class DocumentListWebService < VVA::Base

    def self.service_name
      "document_list"
    end

    def get_by_claim_number(claim_number)
      response = request(:get_document_list, "claimNbr": claim_number)
      response.body[:get_document_list_response][:dcmnt_record].map do |record|
        OpenStruct.new(
          document_id: record[:fn_dcmnt_id],
          restricted: record[:rstrcd_dcmnt_ind] == "Y" ? true : false,
          type_id: record[:dcmnt_type_lup_id],
          type_description: record[:dcmnt_type_descp_txt],
          format: record[:dcmnt_format_cd],
          source: record[:fn_dcmnt_source],
          jro: record[:jrsdtn_ro_nbr],
          ssn: record[:ssn_nbr]
        )
      end
    end
  end
end
