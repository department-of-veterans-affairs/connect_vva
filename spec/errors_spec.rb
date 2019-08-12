require "vva"

describe VVA::HTTPError do
  describe "ignorable?" do
    it "returns false" do
      error = VVA::HTTPError.new(body: "error", code: 500)

      expect(error).to_not be_ignorable
    end
  end
end
