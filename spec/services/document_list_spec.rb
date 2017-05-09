# frozen_string_literal: true
require "spec_helper"

describe VVA::DocumentListWebService do

  context "#get_by_claim_number" do

    it "returns correct information" do
      fixture = File.read("spec/fixtures/document_list_response.xml")
      # set up an expectation
      savon.expects(:get_document_list).with(message: { claimNbr: "456456456" }).returns(fixture)

      service = VVA::DocumentListWebService.new
      response = service.get_by_claim_number("456456456")
      expect(response).to be_an(Array)
      doc1 = response[0]
      expect(doc1.restricted).to eq true
      expect(doc1.document_id).to eq "44674354459"

      doc2 = response[1]
      expect(doc2.restricted).to eq false
      expect(doc2.document_id).to eq "44674356459"
    end
  end
end