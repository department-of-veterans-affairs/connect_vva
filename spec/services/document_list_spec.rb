# frozen_string_literal: true
require "spec_helper"

describe VVA::DocumentListWebService do

  context "#get_by_claim_number" do

    subject { VVA::DocumentListWebService.new.get_by_claim_number("456456456") }

    it "returns correct information" do
      fixture = File.read("spec/fixtures/document_list_response.xml")
      # set up an expectation
      savon.expects(:get_document_list).with(message: { claimNbr: "456456456" }).returns(fixture)

      subject

      expect(subject).to be_an(Array)
      doc1 = subject[0]
      expect(doc1.restricted).to eq true
      expect(doc1.document_id).to eq "{780A881E-65E4-4470-8C9D-72F704469682}"

      doc2 = subject[1]
      expect(doc2.restricted).to eq false
      expect(doc2.document_id).to eq "{17D31E31-AC70-432B-8B26-A502A084A590}"
    end

    it "handles empty list" do
      fixture = File.read("spec/fixtures/no_records_found_response.xml")
      # set up an expectation
      savon.expects(:get_document_list).with(message: { claimNbr: "456456456" }).returns(fixture)

      expect{ subject }.to raise_error(VVA::HTTPError, /No.+records/)
    end
  end
end