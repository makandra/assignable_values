$: << File.join(File.dirname(__FILE__), "/../../lib" )

require 'i18n'
require 'mysql2'
require 'active_record'
require 'assignable_values'
require 'rspec_candy/all'
require 'gemika'

I18n.load_path = [File.join(File.dirname(__FILE__), 'support/i18n.yml')]
I18n.default_locale = :en

ActiveRecord::Base.default_timezone = :local

Dir["#{File.dirname(__FILE__)}/support/*.rb"].sort.each {|f| require f}

Gemika::RSpec.configure_clean_database_before_example
Gemika::RSpec.configure_should_syntax
