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
      tool1 = instance_double("Tool1")
      tool2 = instance_double("Tool2")
      tools = [tool1, tool2]
      agent = described_class.new(name: "TestAgent", tools: tools)
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts a single tool and converts it to an array" do
      tool = instance_double("Tool")
      agent = described_class.new(name: "TestAgent", tools: tool)
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts schema parameter" do
      schema = { type: "object", properties: {} }
      agent = described_class.new(name: "TestAgent", schema: schema)
      expect(agent.name).to eq("TestAgent")
    end

    it "accepts all parameters together" do
      tool = instance_double("Tool")
      agent = described_class.new(
        name: "CompleteAgent",
        options: { model: "gpt-4" },
        tools: [tool],
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
    let(:mock_chat) { instance_double("Chat") }

    it "delegates to chat.ask with the input" do
      allow(agent).to receive(:chat).and_return(mock_chat)
      allow(mock_chat).to receive(:ask).with("test input").and_return("response")

      result = agent.run("test input")

      expect(result).to eq("response")
      expect(mock_chat).to have_received(:ask).with("test input")
    end

    it "passes different inputs to chat.ask" do
      allow(agent).to receive(:chat).and_return(mock_chat)
      allow(mock_chat).to receive(:ask).and_return("response")

      agent.run("first input")
      agent.run("second input")

      expect(mock_chat).to have_received(:ask).with("first input")
      expect(mock_chat).to have_received(:ask).with("second input")
    end
  end

  describe "inheritance" do
    it "inherits from Mars::Runnable" do
      expect(described_class.ancestors).to include(Mars::Runnable)
    end
  end
end
