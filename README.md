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

# Create agents
agent1 = Mars::Agent.new(name: "Agent 1")
agent2 = Mars::Agent.new(name: "Agent 2")
agent3 = Mars::Agent.new(name: "Agent 3")

# Create a sequential workflow
workflow = Mars::Workflows::Sequential.new(
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
agent = Mars::Agent.new(
  name: "My Agent",
  instructions: "You are a helpful assistant",
  options: { model: "gpt-4o" }
)
```

### Sequential Workflows

Execute agents one after another, passing outputs as inputs:

```ruby
sequential = Mars::Workflows::Sequential.new(
  "Sequential Pipeline",
  steps: [agent1, agent2, agent3]
)
```

### Parallel Workflows

Run multiple agents concurrently and aggregate their results:

```ruby
aggregator = Mars::Aggregator.new(
  "Results Aggregator",
  operation: lambda { |results| results.join(", ") }
)

parallel = Mars::Workflows::Parallel.new(
  "Parallel Pipeline",
  steps: [agent1, agent2, agent3],
  aggregator: aggregator
)
```

### Gates

Create conditional branching in your workflows:

```ruby
gate = Mars::Gate.new(
  name: "Decision Gate",
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
diagram = Mars::Rendering::Mermaid.new(workflow).render
File.write("workflow_diagram.md", diagram)
```

## Usage Examples

### Simple LLM Workflow with Conditional Branching

```ruby
require 'mars'

# Configure your LLM provider
RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
end

# Create agents
analyzer = Mars::Agent.new(
  name: "Analyzer",
  instructions: "Analyze the input and provide a summary",
  options: { model: "gpt-4o" }
)

processor = Mars::Agent.new(
  name: "Processor",
  instructions: "Process the analysis further",
  options: { model: "gpt-4o" }
)

# Create a workflow with conditional processing
success_workflow = Mars::Workflows::Sequential.new(
  "Success Path",
  steps: [processor]
)

gate = Mars::Gate.new(
  name: "Quality Gate",
  condition: ->(input) { input.split.length > 10 ? :success : :skip },
  branches: {
    success: success_workflow
  }
)

main_workflow = Mars::Workflows::Sequential.new(
  "Main Pipeline",
  steps: [analyzer, gate]
)

# Run the workflow
result = main_workflow.run("Analyze this text...")
puts result
```

### Parallel Processing with Aggregation

```ruby
# Create multiple specialized agents
summarizer = Mars::Agent.new(name: "Summarizer")
sentiment_analyzer = Mars::Agent.new(name: "Sentiment Analyzer")
keyword_extractor = Mars::Agent.new(name: "Keyword Extractor")

# Define how to combine results
aggregator = Mars::Aggregator.new(
  "Results Combiner",
  operation: lambda { |results|
    {
      summary: results[0],
      sentiment: results[1],
      keywords: results[2]
    }
  }
)

# Create parallel workflow
parallel_analysis = Mars::Workflows::Parallel.new(
  "Parallel Analysis",
  steps: [summarizer, sentiment_analyzer, keyword_extractor],
  aggregator: aggregator
)

result = parallel_analysis.run("Your text to analyze...")
```

### Using Tools and Schemas

```ruby
# Define a custom tool
class WeatherTool < RubyLLM::Tool
  description "Gets current weather for a location"

  params do
    string :latitude, description: "Latitude"
    string :longitude, description: "Longitude"
  end

  def execute(latitude:, longitude:)
    # Your weather API logic here
  end
end

# Define a schema for structured output
class ResponseSchema < RubyLLM::Schema
  object do
    string :location
    number :temperature
    string :conditions
  end
end

# Create an agent with tools and schema
weather_agent = Mars::Agent.new(
  name: "Weather Assistant",
  tools: [WeatherTool.new],
  schema: ResponseSchema.new,
  options: { model: "gpt-4o" }
)
```

### Complex Nested Workflows

```ruby
# Combine sequential and parallel workflows
parallel_phase = Mars::Workflows::Parallel.new(
  "Parallel Processing",
  steps: [agent1, agent2]
)

sequential_phase = Mars::Workflows::Sequential.new(
  "Sequential Refinement",
  steps: [agent3, parallel_phase, agent4]
)

gate = Mars::Gate.new(
  name: "Validation Gate",
  condition: ->(input) { validate(input) ? :continue : :retry },
  branches: {
    continue: sequential_phase
  }
)

complex_workflow = Mars::Workflows::Sequential.new(
  "Complex Pipeline",
  steps: [initial_agent, gate]
)
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

- 📖 [Documentation](https://github.com/rootstrap/mars)
- 💬 [Discussions](https://github.com/rootstrap/mars/discussions)
- 🐛 [Issue Tracker](https://github.com/rootstrap/mars/issues)

## Related Projects

- [ruby_llm](https://github.com/gbaptista/ruby_llm) - Ruby interface for LLM providers

## Code of Conduct

Everyone interacting in the Mars project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rootstrap/mars/blob/main/CODE_OF_CONDUCT.md).

## Credits

Created and maintained by [Rootstrap](https://www.rootstrap.com).
