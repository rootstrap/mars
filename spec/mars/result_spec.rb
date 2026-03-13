# frozen_string_literal: true

RSpec.describe MARS::Result do
  describe ".wrap" do
    it "wraps raw values" do
      expect(described_class.wrap("hello")).to eq(described_class.new(value: "hello"))
    end

    it "passes through result instances" do
      result = described_class.new(value: "hello")
      expect(described_class.wrap(result)).to eq(result)
    end

    it "does not treat domain hashes as envelopes" do
      payload = { country: "Uruguay" }
      expect(described_class.wrap(payload)).to eq(described_class.new(value: payload))
    end
  end

  describe "#[]" do
    it "reads core attributes and step outputs" do
      child = described_class.new(value: "child")
      result = described_class.new(value: "root", stopped: true, outputs: { step: child }, state: { user_id: 1 })

      expect(result[:value]).to eq("root")
      expect(result[:stopped]).to be(true)
      expect(result[:outputs]).to eq(step: child)
      expect(result[:state]).to eq(user_id: 1)
      expect(result[:step]).to eq(child)
    end
  end
end
