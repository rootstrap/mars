# frozen_string_literal: true

require "zeitwerk"
require "async"
require "ruby_llm"
require "ruby_llm/schema"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("mars" => "MARS")
loader.setup

module MARS
  class Error < StandardError; end
end

MARS::Rendering::Graph.include_extensions
