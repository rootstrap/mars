#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/mars"

RubyLLM.configure do |config|
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)
end

# Define schema for sports
class SportsSchema < RubyLLM::Schema
  array :sports do
    object do
      string :name
      array :top_3_players do
        string :name
      end
    end
  end
end

# Define weather tool
class Weather < RubyLLM::Tool
  description "Gets current weather for a location"

  params do
    string :latitude, description: "Latitude (e.g., 52.5200)"
    string :longitude, description: "Longitude (e.g., 13.4050)"
  end

  def execute(latitude:, longitude:)
    url = "https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,wind_speed_10m"
    response = Net::HTTP.get_response(URI(url))
    JSON.parse(response.body)
  rescue StandardError => e
    { error: e.message }
  end
end

# Define LLMs
class Agent1 < Mars::Agent
  def system_prompt
    "You are a helpful assistant that can answer questions.
     When asked about a country, only answer with its name."
  end
end

class Agent2 < Mars::Agent
  def system_prompt
    "You are a helpful assistant that can answer questions and help with tasks.
     Return information about the typical food of the country."
  end
end

class Agent3 < Mars::Agent
  def system_prompt
    "You are a helpful assistant that can answer questions and help with tasks.
     Return information about the popular sports of the country."
  end

  def schema
    SportsSchema.new
  end
end

class Agent4 < Mars::Agent
  def system_prompt
    "You are a helpful assistant that can answer questions and help with tasks.
     Return the current weather of the country's capital."
  end

  def tools
    [Weather.new]
  end
end

# Create the LLMs
llm1 = Agent1.new(options: { model: "gpt-4o" })
llm2 = Agent2.new(options: { model: "gpt-4o" })
llm3 = Agent3.new(options: { model: "gpt-4o" })
llm4 = Agent4.new(options: { model: "gpt-4o" })

parallel_workflow = Mars::Workflows::Parallel.new(
  "Parallel workflow",
  steps: [llm2, llm3, llm4]
)

gate = Mars::Gate.new(
  condition: ->(input) { input.split.length < 10 ? :success : :error },
  branches: {
    success: parallel_workflow
  }
)

sequential_workflow = Mars::Workflows::Sequential.new(
  "Sequential workflow",
  steps: [llm1, gate]
)

# Generate and save the diagram
diagram = Mars::Rendering::Mermaid.new(sequential_workflow).render
File.write("examples/complex_llm_workflow/diagram.md", diagram)
puts "Complex workflow diagram saved to: examples/complex_llm_workflow/diagram.md"

# Run the workflow
puts sequential_workflow.run("Which is the largest country in Europe?")
