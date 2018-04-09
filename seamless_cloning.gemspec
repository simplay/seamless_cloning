lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "seamless_cloning/version"

Gem::Specification.new do |spec|
  spec.name          = "seamless_cloning"
  spec.version       = SeamlessCloning::VERSION
  spec.authors       = ["simplay"]
  spec.email         = ["silent.simplay@gmail.com"]

  spec.summary       = ""
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.extensions = ["ext/seamless_cloning/extconf.rb"]
  spec.require_paths = ["lib", "ext"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_development_dependency "pry", "~> 0.10.4"

  # Adds debug-navigation functionality to pry: step, next, breakpoints ...
  spec.add_development_dependency "pry-byebug", "~> 3.4.2"

  # Core documentation
  spec.add_development_dependency "pry-doc"

  # Print pry debugger output in full color.
  spec.add_development_dependency "awesome_print", "~> 1.7.0"

  # read and write PNG files
  spec.add_runtime_dependency "oily_png"
end
