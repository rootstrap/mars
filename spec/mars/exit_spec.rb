# frozen_string_literal: true

RSpec.describe Mars::Exit do
  describe "#initialize" do
    it "initializes with a default name" do
      exit_node = described_class.new
      expect(exit_node.name).to eq("Exit")
    end

    it "initializes with a custom name" do
      exit_node = described_class.new(name: "CustomExit")
      expect(exit_node.name).to eq("CustomExit")
    end
  end

  describe "#name" do
    it "returns the exit name" do
      exit_node = described_class.new(name: "MyExit")
      expect(exit_node.name).to eq("MyExit")
    end
  end

  describe "#run" do
    let(:exit_node) { described_class.new }

    it "returns the input unchanged" do
      input = "test input"
      result = exit_node.run(input)
      expect(result).to eq(input)
    end

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

    it "returns the exact same object (not a copy)" do
      input = "test"
      result = exit_node.run(input)
      expect(result).to be(input)
    end
  end

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      expect(described_class.ancestors).to include(Mars::Runnable)
    end
  end
end
