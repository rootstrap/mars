# frozen_string_literal: true

RSpec.describe Mars::Exit do
  describe "#run" do
    let(:exit_node) { described_class.new }

    it "works with string inputs" do
      result = exit_node.run("hello")
      expect(result).to eq("hello")
    end

    it "works with numeric inputs" do
      result = exit_node.run(42)
      expect(result).to eq(42)
    end

    it "works with array inputs" do
      input = [1, 2, 3]
      result = exit_node.run(input)
      expect(result).to eq(input)
    end

    it "works with hash inputs" do
      input = { key: "value" }
      result = exit_node.run(input)
      expect(result).to eq(input)
    end

    it "works with nil input" do
      result = exit_node.run(nil)
      expect(result).to be_nil
    end
  end
end
