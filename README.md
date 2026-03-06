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

# Define agents
class Agent1 < MARS::Agent
end

class Agent2 < MARS::Agent
end

class Agent3 < MARS::Agent
end

# Create agents
agent1 = Agent1.new
agent2 = Agent2.new
agent3 = Agent3.new

# Create a sequential workflow
workflow = MARS::Workflows::Sequential.new(
  "My First Workflow",
  steps: [agent1, agent2, agent3]
)

# Run the workflow
result = workflow.run("Your input here")
```

## Core Concepts

### Agents

Agents are the basic building blocks of MARS. They represent individual units of work:

```ruby
class CustomAgent < MARS::Agent
  def system_prompt
    "You are a helpful assistant"
  end
end

agent = CustomAgent.new(
  options: { model: "gpt-4o" }
)
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

Gates act as guards that either let the workflow continue or divert to a fallback path:

```ruby
gate = MARS::Gate.new(
  "Validation Gate",
  check: ->(input) { :failure unless input[:score] > 0.5 },
  fallbacks: {
    failure: failure_workflow
  }
)
```

Control halt scope — `:local` (default) stops only the parent workflow, `:global` propagates to the root:

```ruby
gate = MARS::Gate.new(
  "Critical Gate",
  check: ->(input) { :error unless input[:valid] },
  fallbacks: { error: error_workflow },
  halt_scope: :global
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
