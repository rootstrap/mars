# frozen_string_literal: true

module Mars
  class Gate < Runnable
    include MermaidRenderable

    def initialize(name:, condition:, branches:)
      @name = name
      @condition = condition
      @branches = Hash.new(Exit.new).merge(branches)
    end

    def run(input)
      result = condition.call(input)

      branches[result].run(input)
    end

    def to_mermaid
      gate_id = sanitized_name
      mermaid = ["#{gate_id}{\"#{name}\"}"]

      # Add edges for each branch
      branches.each do |condition_result, branch|
        branch_mermaid = branch.to_mermaid
        mermaid << "#{gate_id} -->|#{condition_result}| #{branch_mermaid}"
      end

      # Add the default exit path
      default_mermaid = branches.default.to_mermaid
      mermaid << "#{gate_id} -->|default| #{default_mermaid}"

      mermaid.join("\n")
    end

    private

    attr_reader :name, :condition, :branches
  end
end
