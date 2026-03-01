# frozen_string_literal: true

RSpec.describe MARS::Rendering::Graph do
  describe "default Runnable rendering" do
    it "renders any Runnable subclass as a box node" do
      step_class = Class.new(MARS::Runnable) do
        def run(input)
          input
        end
      end

      step = step_class.new(name: "custom_step")
      graph, nodes, _subgraphs = step.build_graph

      expect(nodes).to have_key("custom_step")
      expect(nodes["custom_step"].type).to eq(MARS::Rendering::Graph::Node::STEP)
      expect(graph).to have_key("in")
    end
  end

  describe "AgentStep rendering" do
    it "renders as a step node" do
      mock_agent = Class.new
      step_class = Class.new(MARS::AgentStep) do
        agent mock_agent
      end

      step = step_class.new(name: "my_agent")
      _graph, nodes, _subgraphs = step.build_graph

      expect(nodes["my_agent"].type).to eq(MARS::Rendering::Graph::Node::STEP)
    end
  end
end
