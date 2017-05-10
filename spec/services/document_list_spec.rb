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
      expect(doc1.document_id).to eq "{780A881E-65E4-4470-8C9D-72F704469682}"

      doc2 = response[1]
      expect(doc2.restricted).to eq false
      expect(doc2.document_id).to eq "{17D31E31-AC70-432B-8B26-A502A084A590}"
    end
  end
end