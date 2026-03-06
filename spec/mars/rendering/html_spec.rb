# frozen_string_literal: true

RSpec.describe MARS::Rendering::Html do
  it "renders a self-contained HTML page with mermaid diagram" do
    step1 = MARS::AgentStep.new(name: "step1")
    step2 = MARS::AgentStep.new(name: "step2")
    workflow = MARS::Workflows::Sequential.new("pipeline", steps: [step1, step2])

    html = described_class.new(workflow).render

    expect(html).to include("<!DOCTYPE html>")
    expect(html).to include("mermaid")
    expect(html).to include("flowchart LR")
    expect(html).to include("step1")
    expect(html).to include("step2")
    expect(html).to include("mermaid.initialize")
  end

  it "includes the Mermaid CDN script" do
    step = MARS::AgentStep.new(name: "step")
    workflow = MARS::Workflows::Sequential.new("simple", steps: [step])

    html = described_class.new(workflow).render

    expect(html).to include(MARS::Rendering::Html::MERMAID_CDN)
  end
end
