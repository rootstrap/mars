# frozen_string_literal: true

RSpec.describe Mars::Agent do
  describe "#run" do
    subject(:run_agent) { agent.run("input text") }

    let(:agent) { described_class.new(name: "TestAgent", options: { model: "test-model" }) }
    let(:mock_chat_instance) do
      instance_double("RubyLLM::Chat").tap do |mock|
        allow(mock).to receive_messages(with_tools: mock, with_schema: mock, with_instructions: mock,
                                        ask: mock_chat_response)
      end
    end
    let(:mock_chat_response) { instance_double("RubyLLM::Message", content: "response text") }
    let(:mock_chat_class) { class_double("RubyLLM::Chat", new: mock_chat_instance) }

    before do
      stub_const("RubyLLM::Chat", mock_chat_class)
    end

    it "initializes RubyLLM::Chat with provided options" do
      run_agent

      expect(mock_chat_class).to have_received(:new).with(model: "test-model")
    end

    context "when tools are provided" do
      let(:tools) { [proc { "tool1" }, proc { "tool2" }] }
      let(:agent) { described_class.new(name: "TestAgent", tools: tools) }

      it "configures chat with tools" do
        run_agent

        expect(mock_chat_instance).to have_received(:with_tools).with(*tools)
      end
    end

    context "when schema is provided" do
      let(:schema) { { type: "object" } }
      let(:agent) { described_class.new(name: "TestAgent", schema: schema) }

      it "configures chat with schema" do
        run_agent

        expect(mock_chat_instance).to have_received(:with_schema).with(schema)
      end
    end
  end
end
