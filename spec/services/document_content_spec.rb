# frozen_string_literal: true
require "spec_helper"

describe VVA::DocumentContentWebService do

  context "#get_by_document_id" do

    let(:message) do
      # set up an expectation
      message = {
        fnDcmntId: "{DAFE0879-C588-4084-A532-482138F30651}",
        fnDcmntSource: "P8",
        dcmntFormatCd: "pdf",
        jro: "459",
        userId: "987987987"
      }
    end

    let(:service) { VVA::DocumentContentWebService.new }
    let(:response) do
      service.get_by_document_id(
        document_id: "{DAFE0879-C588-4084-A532-482138F30651}",
        source: "P8",
        format: "pdf",
        jro: "459",
        ssn: "987987987"
      )
    end

    it "returns correct information" do
      fixture = File.read("spec/fixtures/document_content_response.xml")
      savon.expects(:get_document_content).with(message: message).returns(fixture)
      expect(response).to be_an(OpenStruct)
      expect(response.content).to_not be nil
      expect(response.mime_type).to eq "application/octet-stream"
    end

    it "works when content is empty" do
      fixture = File.read("spec/fixtures/document_with_no_content_response.xml")
      savon.expects(:get_document_content).with(message: message).returns(fixture)
      expect(response).to be_an(OpenStruct)
      expect(response.content).to eq ""
      expect(response.mime_type).to eq "application/octet-stream"
    end
  end
end