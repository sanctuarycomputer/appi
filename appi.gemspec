$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "appi/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "appi"
  s.version     = APPI::VERSION
  s.authors     = ["Hugh Francis"]
  s.email       = ["me@hughfrancis.me"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Appi."
  s.description = "TODO: Description of Appi."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.2"
  s.add_dependency "email_validator", "~> 1.6.0"
  s.add_dependency "jwt"

  s.add_development_dependency "sqlite3"
end
