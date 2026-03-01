# MARS (Multi-Agent Ruby SDK)

[![Gem Version](https://badge.fury.io/rb/mars_rb.svg)](https://badge.fury.io/rb/mars_rb)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

MARS (Multi-Agent Ruby SDK) provides a comprehensive framework for developers to implement multi-agent solutions using pure Ruby. It offers a simple, intuitive API for orchestrating multiple agents with support for sequential and parallel workflows, conditional branching, and visual workflow diagrams.

## Features

- 🤖 **Agent Orchestration**: Coordinate multiple agents with ease
- 🔄 **Sequential Workflows**: Chain agents to execute tasks in order
- ⚡ **Parallel Workflows**: Run multiple agents concurrently
- 🚦 **Conditional Gates**: Branch workflows based on runtime conditions
- 🔧 **Aggregators**: Combine results from parallel operations
- 📊 **Visual Diagrams**: Generate Mermaid diagrams of your workflows
- 🔌 **LLM Integration**: Built-in support for LLM agents via [ruby_llm](https://github.com/gbaptista/ruby_llm)
- 🛠️ **Tools & Schemas**: Define custom tools and structured outputs for agents

## Requirements

- Ruby >= 3.1.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mars_rb'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install mars_rb
```

## Quick Start

Here's a simple example to get you started:

```ruby
require 'mars'

# Define a RubyLLM agent
class MyAgent < RubyLLM::Agent
  model "gpt-4o"
  instructions "You are a helpful assistant."
end

# Wrap it in a MARS step
class MyStep < MARS::AgentStep
  agent MyAgent
end

# Create steps
step1 = MyStep.new(name: "step1")
step2 = MyStep.new(name: "step2")
step3 = MyStep.new(name: "step3")

# Create a sequential workflow
workflow = MARS::Workflows::Sequential.new(
  "My First Workflow",
  steps: [step1, step2, step3]
)

# Run the workflow
context = workflow.run("Your input here")
context.current_input  # final output
context[:step1]        # access any step's output by name
```

## Core Concepts

### Agent Steps

Agent steps are the basic building blocks of MARS. They wrap a `RubyLLM::Agent` subclass for workflow orchestration:

```ruby
class ResearcherAgent < RubyLLM::Agent
  model "gpt-4o"
  instructions "You research topics thoroughly."
  tools WebSearch
  schema OutputSchema
end

class ResearcherStep < MARS::AgentStep
  agent ResearcherAgent
end

step = ResearcherStep.new(name: "researcher")
```

### Sequential Workflows

Execute agents one after another, passing outputs as inputs:

```ruby
sequential = MARS::Workflows::Sequential.new(
  "Sequential Pipeline",
  steps: [agent1, agent2, agent3]
)
```

### Parallel Workflows

Run multiple agents concurrently and aggregate their results:

```ruby
aggregator = MARS::Aggregator.new(
  "Results Aggregator",
  operation: lambda { |results| results.join(", ") }
)

parallel = MARS::Workflows::Parallel.new(
  "Parallel Pipeline",
  steps: [agent1, agent2, agent3],
  aggregator: aggregator
)
```

### Gates

Create conditional branching in your workflows:

```ruby
gate = MARS::Gate.new(
  "Decision Gate",
  condition: ->(input) { input[:score] > 0.5 ? :success : :failure },
  branches: {
    success: success_workflow,
    failure: failure_workflow
  }
)
```

### Visualization

Generate Mermaid diagrams to visualize your workflows:

```ruby
diagram = MARS::Rendering::Mermaid.new(workflow).render
File.write("workflow_diagram.md", diagram)
```

## Examples

Check out the [examples](examples/) directory for more detailed examples:

- [Simple Workflow](examples/simple_workflow/) - Basic sequential workflow with gates
- [Parallel Workflow](examples/parallel_workflow/) - Concurrent agent execution
- [Complex Workflow](examples/complex_workflow/) - Nested workflows with multiple gates
- [Complex LLM Workflow](examples/complex_llm_workflow/) - Real-world LLM integration with tools and schemas

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Testing

Run the test suite with:

```bash
bundle exec rake spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rootstrap/mars. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rootstrap/mars/blob/main/CODE_OF_CONDUCT.md).

To contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to:
- Write tests for new features
- Update documentation as needed
- Follow the existing code style
- Ensure all tests pass before submitting

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Support

- 🐛 [Issue Tracker](https://github.com/rootstrap/mars/issues)

## Related Projects

- [ruby_llm](https://github.com/gbaptista/ruby_llm) - Ruby interface for LLM providers

## Code of Conduct

Everyone interacting in the MARS project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rootstrap/mars/blob/main/CODE_OF_CONDUCT.md).

## Credits

Created and maintained by [Rootstrap](https://www.rootstrap.com).
