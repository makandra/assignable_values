$:.push File.expand_path("../lib", __FILE__)
require "assignable_values/version"

Gem::Specification.new do |s|
  s.name = 'assignable_values'
  s.version = AssignableValues::VERSION
  s.authors = ["Henning Koch"]
  s.email = 'henning.koch@makandra.de'
  s.homepage = 'https://github.com/makandra/assignable_values'
  s.summary = 'Restrict the values assignable to ActiveRecord attributes or associations'
  s.description = s.summary
  s.license = 'MIT'

  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(%r{^spec/})
  s.require_paths = ["lib"]

  s.add_dependency('activerecord', '>=2.3')
end
