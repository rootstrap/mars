# frozen_string_literal: true

RSpec.describe Mars::Agent do
  describe "#run" do
    let(:agent) { described_class.new(name: "TestAgent", options: { model: "test-model" }) }
    let(:mock_chat_instance) do
      instance_double("RubyLLM::Chat").tap do |mock|
        allow(mock).to receive_messages(with_tools: mock, with_schema: mock, ask: nil)
      end
    end
    let(:mock_chat_class) { class_double("RubyLLM::Chat", new: mock_chat_instance) }

    before do
      stub_const("RubyLLM::Chat", mock_chat_class)
    end

    it "initializes RubyLLM::Chat with provided options" do
      agent.run("test input")

      expect(mock_chat_class).to have_received(:new).with(model: "test-model")
    end

    it "configures chat with tools if provided" do
      tools = [proc { "tool" }]
      agent_with_tools = described_class.new(name: "TestAgent", tools: tools)
      agent_with_tools.run("test input")

      expect(mock_chat_instance).to have_received(:with_tools).with(tools)
    end

    it "configures chat with schema if provided" do
      schema = { type: "object" }
      agent_with_schema = described_class.new(name: "TestAgent", schema: schema)

      agent_with_schema.run("test input")
      expect(mock_chat_instance).to have_received(:with_schema).with(schema)
    end
  end
end
