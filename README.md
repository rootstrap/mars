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
class ResolveCountryAgent < RubyLLM::Agent
  instructions "Answer with only the country name."
end

# Wrap the agent in a MARS step
class ResolveCountry < MARS::AgentStep
  agent ResolveCountryAgent
end

# Plain Ruby steps subclass MARS::Step
class ResearchFood < MARS::Step
  def run(input, ctx: {})
    result(value: "Typical food of #{input.value}")
  end
end

class ResearchSports < MARS::Step
  def run(input, ctx: {})
    result(value: "Popular sports of #{input.value}")
  end
end

class BuildReport < MARS::Aggregator
  def run(results, ctx: {})
    result(
      value: {
        country: ctx[:resolve_country].value,
        food: results[0].value,
        sports: results[1].value
      }
    )
  end
end

workflow = MARS::Workflows::Sequential.new(
  "Country Report",
  steps: [
    ResolveCountry.new,
    MARS::Workflows::Parallel.new(
      "country_details",
      steps: [
        ResearchFood.new,
        ResearchSports.new
      ],
      aggregator: BuildReport.new
    )
  ]
)

result = workflow.run("Your input here")
pp result.value
```

## Core Concepts

### Steps

Every executable object in MARS responds to `run`. Plain Ruby steps subclass `MARS::Step`:

```ruby
class NormalizeQuestion < MARS::Step
  def run(input, ctx: {})
    result(value: input.value.strip)
  end
end

step = NormalizeQuestion.new
```

### Agent Steps

`MARS::AgentStep` is a thin wrapper around a configured `RubyLLM::Agent`:

```ruby
class CountryAgent < RubyLLM::Agent
  instructions "Answer with only the country name."
end

class ResolveCountry < MARS::AgentStep
  agent CountryAgent
end
```

### Sequential Workflows

Sequential workflows execute steps one after another, passing the previous output to the next step:

```ruby
workflow = MARS::Workflows::Sequential.new(
  "Sequential Pipeline",
  steps: [ResolveCountry.new, NormalizeQuestion.new]
)
```

### Parallel Workflows

Parallel workflows use ordered `steps:`. Without an aggregator they return an array of step outputs. With an aggregator they return a single value:

```ruby
class BuildReport < MARS::Aggregator
  def run(results, ctx: {})
    result(
      value: {
        country: ctx[:resolve_country].value,
        food: results[0].value,
        sports: results[1].value
      }
    )
  end
end

parallel = MARS::Workflows::Parallel.new(
  "Parallel Pipeline",
  steps: [
    ResearchFood.new,
    ResearchSports.new
  ],
  aggregator: BuildReport.new
)
```

### Gates

Gates branch out of the happy path when a condition matches. If the `check` returns `nil`, the workflow continues normally. If it returns a branch key, the selected branch runs and the current workflow stops:

```ruby
class TooBroad < MARS::Step
  def run(input, ctx: {})
    result(
      value: {
        error: "Please ask about one country",
        resolved_value: input.value
      }
    )
  end
end

gate = MARS::Gate.new(
  "country_guard",
  check: ->(input, _ctx) { :too_broad if input.value.split.size > 5 },
  branches: {
    too_broad: TooBroad.new
  }
)
```

### Context And Result

Steps receive a shared `ctx:` object and workflows always return `MARS::Result`:

```ruby
result = workflow.run("Which is the largest country in Europe?")

result.value                # final workflow output
result.outputs[:research_food] # output captured for a step
result.stopped?             # whether a gate branched out of the happy path
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
