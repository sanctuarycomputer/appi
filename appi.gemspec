$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "appi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "appi"
  s.version     = APPI::VERSION
  s.authors     = ["Hugh Francis"]
  s.email       = ["hugh@sanctuary.computer"]
  s.homepage    = "https://github.com/sanctuarycomputer/appi"
  s.summary     = "A minimal toolkit for building modern, stateless JSON APIs."
  s.description = "A minimal toolkit for building modern, stateless APIs, perfect for single page applications. Built with Ember CLI in mind, but framework agnostic. Use as much or as little as you need."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4", "> 4"
  s.add_dependency "email_validator", "~> 1.6", ">= 1.6.0"
  s.add_dependency "jwt", '~> 1.0', '>= 1.0.0'
end
