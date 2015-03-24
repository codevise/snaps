$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "snaps/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "snaps"
  s.version     = Snaps::VERSION
  s.authors     = ['Codevise Solutions Ltd']
  s.email       = ['info@codevise.de']
  s.homepage    = "https://github.com/codevise/snaps"
  s.summary     = "TODO: Summary of Snaps."
  s.description = "TODO: Description of Snaps."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,spec/factories}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.1"

  s.add_development_dependency "sqlite3"

  # Testing framework
  s.add_development_dependency 'rspec-rails', '~> 2.14'

  s.add_development_dependency 'timecop'

  # Fixture replacement
  s.add_development_dependency 'factory_girl_rails', '~> 4.5'
end
