$: << File.join(File.dirname(__FILE__), "/../../lib" )

require 'i18n'
require 'active_record'
require 'assignable_values'
require 'rspec_candy/all'
require 'gemika'

I18n.enforce_available_locales = true
I18n.load_path = [File.join(File.dirname(__FILE__), 'support/i18n.yml')]
I18n.default_locale = :en

# This API has changed from Rails 6 to Rails 7, we need to handle both cases until we drop Rails 6 support.
if ActiveRecord.respond_to?(:default_timezone)
  ActiveRecord.default_timezone = :local
else
  ActiveRecord::Base.default_timezone = :local
end

Dir["#{File.dirname(__FILE__)}/support/*.rb"].sort.each {|f| require f}

Gemika::RSpec.configure_clean_database_before_example
Gemika::RSpec.configure_should_syntax
