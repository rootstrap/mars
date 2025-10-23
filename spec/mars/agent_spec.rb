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
    let(:agent) { described_class.new(name: "TestAgent") }
    let(:mock_chat) { double("chat") }

    it "delegates to chat.ask with the input" do
      allow(agent).to receive(:chat).and_return(mock_chat)
      expect(mock_chat).to receive(:ask).with("test input").and_return("response")
      
      result = agent.run("test input")
      expect(result).to eq("response")
    end

    it "calls chat method to get the chat instance" do
      allow(agent).to receive(:chat).and_return(mock_chat)
      allow(mock_chat).to receive(:ask).and_return("response")
      
      expect(agent).to receive(:chat).at_least(:once)
      agent.run("input")
    end

    it "passes different inputs to chat.ask" do
      allow(agent).to receive(:chat).and_return(mock_chat)
      
      expect(mock_chat).to receive(:ask).with("first input").and_return("first response")
      expect(mock_chat).to receive(:ask).with("second input").and_return("second response")
      
      expect(agent.run("first input")).to eq("first response")
      expect(agent.run("second input")).to eq("second response")
    end
  end

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      expect(described_class.ancestors).to include(Mars::Runnable)
    end
  end
end
