# frozen_string_literal: true

RSpec.describe MARS::Rendering::Mermaid do
  it "renders a custom Runnable subclass as a box node" do
    step = Class.new(MARS::Runnable) do
      def run(input, ctx: {}) = input
    end.new(name: "custom_step")

    mermaid = described_class.new(step)
    output = mermaid.render

    expect(output).to include("custom_step[custom_step]")
  end

  it "renders an AgentStep as a box node" do
    step = MARS::AgentStep.new(name: "my_agent")
    mermaid = described_class.new(step)
    output = mermaid.render

    expect(output).to include("my_agent[my_agent]")
  end

  it "renders a Gate as a diamond node" do
    gate = MARS::Gate.new(
      "my_gate",
      check: ->(_input, _ctx) { :branch },
      fallbacks: {
        branch: Class.new(MARS::Runnable) do
          def run(input, ctx: {}) = input
        end.new(name: "branch_step")
      }
    )

    mermaid = described_class.new(gate)
    output = mermaid.render

    expect(output).to include("my_gate{my_gate}")
    expect(output).to include("|branch|")
  end

  it "renders a Sequential workflow with subgraph" do
    step1 = MARS::AgentStep.new(name: "step1")
    step2 = MARS::AgentStep.new(name: "step2")
    workflow = MARS::Workflows::Sequential.new("pipeline", steps: [step1, step2])

    mermaid = described_class.new(workflow)
    output = mermaid.render

    expect(output).to include("subgraph pipeline")
    expect(output).to include("step1[step1]")
    expect(output).to include("step2[step2]")
  end

  it "renders a Parallel workflow with aggregator" do
    step1 = MARS::AgentStep.new(name: "step1")
    step2 = MARS::AgentStep.new(name: "step2")
    workflow = MARS::Workflows::Parallel.new(
      "parallel",
      steps: [step1, step2],
      aggregator: MARS::Aggregator.new("parallel aggregator")
    )

    mermaid = described_class.new(workflow)
    output = mermaid.render

    expect(output).to include("subgraph parallel")
    expect(output).to include("step1[step1]")
    expect(output).to include("step2[step2]")
    expect(output).to include("parallel_aggregator")
  end
end
