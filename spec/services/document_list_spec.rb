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
      expect(doc1.series_id).to eq "{780A881E-65E4-4470-8C9D-72F704469682}"
      expect(doc1.version).to eq "1"
      expect(doc1.downloaded_from).to eq "VVA"
      expect(doc1.received_at).to be_a(Date)
      expect(doc1.upload_date).to be_a(Date)

      doc2 = subject[1]
      expect(doc2.restricted).to eq false
      expect(doc2.document_id).to eq "{17D31E31-AC70-432B-8B26-A502A084A590}"
      expect(doc2.received_at).to eq nil
    end

    it "handles empty list" do
      fixture = File.read("spec/fixtures/no_records_found_response.xml")
      # set up an expectation
      savon.expects(:get_document_list).with(message: { claimNbr: "456456456" }).returns(fixture)

      expect(subject).to eq []
    end

    it "handles one record without error" do
      fixture = File.read("spec/fixtures/one_record_response.xml")
      # set up an expectation
      savon.expects(:get_document_list).with(message: { claimNbr: "456456456" }).returns(fixture)

      expect(subject).to be_an(Array)
      expect(subject.size).to eq 1
      expect(subject[0].document_id).to eq "{780A881E-65E4-4470-8C9D-72F704469682}"
    end
  end

  context "when VVA returns a 503 response" do
    let(:err_msg) { "upstream connect error or disconnect/reset before headers" }
    before do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(
        Savon::HTTPError.new(HTTPI::Response.new(503, {}, err_msg))
      )
    end

    it "raises a VVA::HTTPError to the calling code" do
      expect { VVA::DocumentListWebService.new.get_by_claim_number("19891213") }.to raise_error(VVA::HTTPError, /#{err_msg}/)
    end
  end

  context "when VVA encounters an openssl error" do
    let(:err_msg) { "SSL_connect SYSCALL returned=5 errno=0 state=SSLv2/v3 read server hello A" }
    before do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(
        HTTPI::SSLError.new(err_msg)
      )
    end

    it "raises a VVA::HTTPError to the calling code" do
      expect { VVA::DocumentListWebService.new.get_by_claim_number("19120623") }.to raise_error(VVA::SSLError, /#{err_msg}/)
    end
  end
end
