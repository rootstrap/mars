# frozen_string_literal: true

RSpec.describe Mars::Agent do
  describe "#initialize" do
    it "initializes with a name" do
      agent = described_class.new(name: "TestAgent")
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts options parameter" do
      options = { model: "gpt-4", temperature: 0.7 }
      agent = described_class.new(name: "TestAgent", options: options)
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts tools parameter as an array" do
      tools = [double("tool1"), double("tool2")]
      agent = described_class.new(name: "TestAgent", tools: tools)
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts a single tool and converts it to an array" do
      tool = double("tool")
      agent = described_class.new(name: "TestAgent", tools: tool)
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts schema parameter" do
      schema = { type: "object", properties: {} }
      agent = described_class.new(name: "TestAgent", schema: schema)
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts all parameters together" do
      agent = described_class.new(
        name: "CompleteAgent",
        options: { model: "gpt-4" },
        tools: [double("tool")],
        schema: { type: "object" }
      )
      expect(agent.name).to eq("CompleteAgent")
    end
  end

  describe "#name" do
    it "returns the agent name" do
      agent = described_class.new(name: "MyAgent")
      expect(agent.name).to eq("MyAgent")
    end
  end

  describe "#run" do
    let(:mock_chat) { instance_double(RubyLLM::Chat) }
    let(:agent) { described_class.new(name: "TestAgent") }

    before do
      allow(RubyLLM::Chat).to receive(:new).and_return(mock_chat)
      allow(mock_chat).to receive(:with_tools).and_return(mock_chat)
      allow(mock_chat).to receive(:with_schema).and_return(mock_chat)
    end

    it "delegates to chat.ask with the input" do
      expect(mock_chat).to receive(:ask).with("test input").and_return("response")
      result = agent.run("test input")
      expect(result).to eq("response")
    end

    it "creates chat with provided options" do
      options = { model: "gpt-4", temperature: 0.5 }
      agent = described_class.new(name: "TestAgent", options: options)
      
      expect(RubyLLM::Chat).to receive(:new).with(**options).and_return(mock_chat)
      allow(mock_chat).to receive(:ask).with("input").and_return("output")
      
      agent.run("input")
    end

    it "reuses the same chat instance across multiple runs" do
      allow(mock_chat).to receive(:ask).and_return("response")
      
      expect(RubyLLM::Chat).to receive(:new).once.and_return(mock_chat)
      
      agent.run("first input")
      agent.run("second input")
    end
  end

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      expect(described_class.ancestors).to include(Mars::Runnable)
    end
  end
end
