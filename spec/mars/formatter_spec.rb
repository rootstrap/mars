# frozen_string_literal: true

RSpec.describe MARS::Formatter do
  let(:formatter) { described_class.new }

  describe "#format_input" do
    it "returns the context's current_input" do
      context = MARS::ExecutionContext.new(input: "hello")
      expect(formatter.format_input(context)).to eq("hello")
    end
  end

  describe "#format_output" do
    it "returns the output unchanged" do
      expect(formatter.format_output("result")).to eq("result")
    end
  end

  describe "custom formatter" do
    let(:custom_formatter_class) do
      Class.new(described_class) do
        def format_input(context)
          context.current_input.upcase
        end

        def format_output(output)
          "formatted: #{output}"
        end
      end
    end

    let(:custom_formatter) { custom_formatter_class.new }

    it "can override format_input" do
      context = MARS::ExecutionContext.new(input: "hello")
      expect(custom_formatter.format_input(context)).to eq("HELLO")
    end

    it "can override format_output" do
      expect(custom_formatter.format_output("result")).to eq("formatted: result")
    end
  end
end
