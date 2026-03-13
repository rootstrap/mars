# frozen_string_literal: true

RSpec.describe MARS::Formatter do
  let(:formatter) { described_class.new }

  describe "#format_input" do
    it "returns the context's current_input" do
      context = MARS::Context.new(input: "hello")
      expect(formatter.format_input(context)).to eq(MARS::Result.new(value: "hello"))
    end
  end

  describe "#format_output" do
    it "normalizes raw output into a result" do
      expect(formatter.format_output("result")).to eq(MARS::Result.new(value: "result"))
    end
  end

  describe "custom formatter" do
    let(:custom_formatter_class) do
      Class.new(described_class) do
        def format_input(context)
          MARS::Result.new(value: context.current_input.value.upcase)
        end

        def format_output(output)
          MARS::Result.new(value: "formatted: #{output.value}", stopped: output.stopped?)
        end
      end
    end

    let(:custom_formatter) { custom_formatter_class.new }

    it "can override format_input" do
      context = MARS::Context.new(input: "hello")
      expect(custom_formatter.format_input(context)).to eq(MARS::Result.new(value: "HELLO"))
    end

    it "can override format_output" do
      expect(custom_formatter.format_output(MARS::Result.new(value: "result")))
        .to eq(MARS::Result.new(value: "formatted: result"))
    end
  end
end
