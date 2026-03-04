# frozen_string_literal: true

RSpec.describe MARS::Halt do
  describe "#scope" do
    it "defaults to :local" do
      halt = described_class.new("result")
      expect(halt.scope).to eq(:local)
      expect(halt).to be_local
      expect(halt).not_to be_global
    end

    it "can be set to :global" do
      halt = described_class.new("result", scope: :global)
      expect(halt.scope).to eq(:global)
      expect(halt).to be_global
      expect(halt).not_to be_local
    end
  end

  describe "#result" do
    it "stores the result" do
      halt = described_class.new("hello")
      expect(halt.result).to eq("hello")
    end
  end
end
