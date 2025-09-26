# frozen_string_literal: true

require_relative "lib/mars/version"

Gem::Specification.new do |spec|
  spec.name = "mars_rb"
  spec.version = Mars::VERSION
  spec.authors = ["Santiago Bartesaghi", "Andres Garcia", "Ignacio Perez", "Santiago Diaz"]
  spec.email = ["sbartesaghi@hotmail.com", "andres@rootstrap.com", "ignacio.perez@rootstrap.com",
                "santiago.diaz@rootstrap.com"]

  spec.summary = "Multi-Agent Ruby SDK - A framework for building multi-agent solutions in pure Ruby"
  spec.description = "MARS (Multi-Agent Ruby SDK) provides a comprehensive framework for developers to implement" \
                     "multi-agent solutions using pure Ruby. It offers a simple API for orchestrating multiple agents."
  spec.homepage = "https://github.com/rootstrap/mars"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rootstrap/mars"
  spec.metadata["changelog_uri"] = "https://github.com/rootstrap/mars/releases"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
