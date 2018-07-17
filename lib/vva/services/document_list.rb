module VVA

  class DocumentListWebService < VVA::Base

    # according to VVA documentation, there are only two mime types: TIFF and PDF
    MIME_TYPES = {
      "tiff" => "image/tiff",
      "pdf" => "application/pdf"
    }.freeze

    def self.service_name
      "document_list"
    end

    def get_by_claim_number(claim_number)
      response = request(:get_document_list, "claimNbr": claim_number)
      document_list = response.body[:get_document_list_response][:dcmnt_record]

      return [] if document_list.blank?
      # Savon parses one item list as a Hash instead of an Array
      [document_list].flatten.map { |r| create_record(r) }
    end

    private

    def create_record(record)
      OpenStruct.new(
        document_id: record[:fn_dcmnt_id],
        series_id: record[:fn_dcmnt_id],
        version: "1",
        restricted: record[:rstrcd_dcmnt_ind] == "Y" ? true : false,
        type_id: record[:dcmnt_type_lup_id],
        type_description: record[:dcmnt_type_descp_txt],
        mime_type: MIME_TYPES[record[:dcmnt_format_cd].downcase],
        received_at: record[:rcvd_dt].nil? ? nil : Time.strptime(record[:rcvd_dt], "%m/%d/%Y").to_date,
        upload_date: record[:storg_dt].nil? ? nil : Time.strptime(record[:storg_dt], "%m/%d/%Y").to_date,
        format: record[:dcmnt_format_cd],
        source: record[:fn_dcmnt_source],
        jro: record[:jrsdtn_ro_nbr],
        ssn: record[:ssn_nbr],
        downloaded_from: "VVA"
      )
    end
  end
end
