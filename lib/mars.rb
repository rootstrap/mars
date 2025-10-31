# frozen_string_literal: true

require "zeitwerk"
require "async"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Mars
  class Error < StandardError; end
end

Mars::Rendering::Graph.include_extensions
