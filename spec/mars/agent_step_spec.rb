# frozen_string_literal: true

RSpec.describe MARS::AgentStep do
  describe ".agent" do
    it "stores and retrieves the agent class" do
      agent_class = Class.new
      step_class = Class.new(described_class) do
        agent agent_class
      end

      expect(step_class.agent).to eq(agent_class)
    end

    it "returns nil when no agent class is set" do
      step_class = Class.new(described_class)
      expect(step_class.agent).to be_nil
    end
  end

  describe "#run" do
    let(:mock_agent_instance) do
      instance_double("RubyLLM::Agent").tap do |mock|
        allow(mock).to receive(:ask).and_return(instance_double("RubyLLM::Message", content: "agent response"))
      end
    end

    let(:mock_agent_class) do
      instance_double("Class").tap do |mock|
        allow(mock).to receive(:new).and_return(mock_agent_instance)
      end
    end

    let(:step_class) do
      klass = mock_agent_class
      Class.new(described_class) do
        agent klass
      end
    end

    it "creates a new agent instance and calls ask" do
      step = step_class.new
      result = step.run(MARS::ExecutionContext.new(input: "hello"))

      expect(result).to eq("agent response")
      expect(mock_agent_class).to have_received(:new)
      expect(mock_agent_instance).to have_received(:ask).with("hello")
    end
  end

  describe "inheritance" do
    it "inherits from MARS::Runnable" do
      expect(described_class.ancestors).to include(MARS::Runnable)
    end

    it "has access to name, formatter, and hooks from Runnable" do
      step = described_class.new(name: "my_agent")
      expect(step.name).to eq("my_agent")
      expect(step.formatter).to be_a(MARS::Formatter)
    end
  end
end
