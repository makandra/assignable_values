$:.push File.expand_path("../lib", __FILE__)
require "assignable_values/version"

Gem::Specification.new do |s|
  s.name = 'assignable_values'
  s.version = AssignableValues::VERSION
  s.authors = ["Henning Koch"]
  s.email = 'henning.koch@makandra.de'
  s.homepage = 'https://github.com/makandra/assignable_values'
  s.summary = 'Restrict the values assignable to ActiveRecord attributes or associations. Or enums on steroids.'
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activerecord')

  s.add_development_dependency('rails', '~>3.1')
  s.add_development_dependency('rspec', '~>2.8')
  s.add_development_dependency('rspec-rails', '~>2.8')
  s.add_development_dependency('sqlite3')
end
