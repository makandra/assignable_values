assignable_values - Enums on vitamins [![Build Status](https://secure.travis-ci.org/makandra/assignable_values.png?branch=master)](https://travis-ci.org/makandra/assignable_values) [![Code Climate](https://codeclimate.com/github/makandra/assignable_values.png)](https://codeclimate.com/github/makandra/assignable_values)
=====================================

`assignable_values` lets you restrict the values that can be assigned to attributes or associations of ActiveRecord models. You can think of it as enums where the list of allowed values is generated at runtime and the value is checked during validation.

We carefully enhanced the core enum functionality with small tweaks that are useful for web forms, internationalized applications and common authorization patterns.

`assignable_values` is tested with Rails 2.3, 3.2, 4.2 and 5.0 on Ruby 1.8.7, 2.1 and 2.3.


Restricting scalar attributes
-----------------------------

The basic usage to restrict the values assignable to strings, integers, etc. is this:

    class Song < ActiveRecord::Base
      assignable_values_for :genre do
        ['pop', 'rock', 'electronic']
      end
    end

The assigned value is checked during validation:

    Song.new(:genre => 'rock').valid?     # => true
    Song.new(:genre => 'elephant').valid? # => false

The validation error message is the same as the one from `validates_inclusion_of` (`errors.messages.inclusion` in your I18n dictionary).
You can also set a custom error message with the `:message` option.


### Listing assignable values

You can ask a record for a list of values that can be assigned to an attribute:

    song.assignable_genres # => ['pop', 'rock', 'electronic']

This is useful for populating `<select>` tags in web forms:

    form.select :genre, form.object.assignable_genres


### Humanized labels

You will often want to present internal values in a humanized form. E.g. `"pop"` should be presented as `"Pop music"`.

You can define human labels in your I18n dictionary:

    en:
      assignable_values:
        song:
          genre:
            pop: 'Pop music'
            rock: 'Rock music'
            electronic: 'Electronic music'

You can access the humanized version for the current value like this:

    song = Song.new(:genre => 'pop')
    song.humanized_genre # => 'Pop music'

Or you can retrieve the humanized version of any given value by passing it as an argument to either instance or class:

    song.humanized_genre('rock') # => 'Rock music'
    Song.humanized_genre('rock') # => 'Rock music'

You can obtain a list of all assignable values with their humanizations:

    song.humanized_genres.size            # => 3
    song.humanized_genres.first.value     # => "pop"
    song.humanized_genres.first.humanized # => "Pop music"

A good way to populate a `<select>` tag with pairs of internal values and human labels is to use the `collection_select` helper from Rails:

    form.collection_select :genre, form.object.humanized_genres, :value, :humanized

If you don't like to use your I18n dictionary for humanizations, you can also declare them directly in your model like this:

    class Song < ActiveRecord::Base
      assignable_values_for :genre do
        { 'pop' => 'Pop music',
          'rock' => 'Rock music',
          'electronic' => 'Electronic music' }
      end
    end


### Defining default values

You can define a default value by using the `:default` option:

    class Song < ActiveRecord::Base
      assignable_values_for :genre, :default => 'rock' do
        ['pop', 'rock', 'electronic']
      end
    end

The default is applied to new records:

    Song.new.genre # => 'rock'

Defaults can be procs:

    class Song < ActiveRecord::Base
      assignable_values_for :genre, :default => proc { Date.today.year } do
        1980 .. 2011
      end
    end

The proc will be evaluated in the context of the record instance.

You can also default a secondary default that is only set if the primary default value is not assignable:

    class Song < ActiveRecord::Base
      assignable_values_for :year, :default => 1999, :secondary_default => lambda { Date.today.year } do
        (Date.today.year - 2) .. Date.today.year
      end
    end

If called in 2013 the code above will fall back to:

    Song.new.year # => 2013


### Allowing blank values

By default, an attribute *must* be assigned an value. If the value of an attribute is blank, the attribute
will get a validation error.

If you would like to change this behavior and allow blank values to be valid, use the `:allow_blank` option:

    class Song < ActiveRecord::Base
      assignable_values_for :genre, :default => 'rock', :allow_blank => true do
        ['pop', 'rock', 'electronic']
      end
    end

The `:allow_blank` option can be a symbol, in which case a method of that name will be called on the record.

The `:allow_blank` option can also be a lambda, in which case the lambda will be called in the context of the record.


### Values are only validated when they change

Values are only validated when they change. This is useful when the list of assignable values can change during runtime:

    class Song < ActiveRecord::Base
      assignable_values_for :year do
        (Date.today.year - 2) .. Date.today.year
      end
    end

If a value has been saved before, it will remain valid, even if it is no longer assignable:

    Song.update_all(:year => 1985) # update all records with a value that is no longer valid
    song = Song.last
    song.year # => 1985
    song.valid?  # => true

It will also be returned when obtaining the list of assignable values:

    song.assignable_years # => [2010, 2011, 2012, 1985]

However, if you want only those values that are actually intended to be assignable, e.g. when updating a `<select>` via AJAX, pass an option:

    song.assignable_years(include_old_value: false) # => [2010, 2011, 2012]

Once a changed value has been saved, the previous value disappears from the list of assignable values:

    song.year = '2010'
    song.save!
    song.assignable_years # => [2010, 2011, 2012]
    song.year = 1985
    song.valid? # => false

This is to prevent records from becoming invalid as the list of assignable values evolves. This also prevents `<select>` menus with blank selections when opening an old record in a web form.


Restricting belongs_to associations
-----------------------------------

You can restrict `belongs_to` associations in the same manner as scalar attributes:

    class Song < ActiveRecord::Base

      belongs_to :artist

      assignable_values_for :artist do
        Artist.where(:signed => true)
      end

    end

Listing and validating als works the same:

    chicane = Artist.create!(:name => 'Chicane', :signed => true)
    lt2 = Artist.create!(:name => 'LT2', :signed => false)

    song = Song.new

    song.assignable_artists # => [#<Artist id: 1, name: "Chicane">]

    song.artist = chicane
    song.valid? # => true

    song.artist = lt2
    song.valid? # => false

Similiar to scalar attributes, associations are only validated when the foreign key (`artist_id` in the example above) changes.
Values stored in the database will remain assignable until they are changed, and you can query actually assignable values with `song.assignable_artists(include_old_value: false)`.

Validation errors will be attached to the association's foreign key (`artist_id` in the example above).


How assignable values are evaluated
-----------------------------------

The list of assignable values is generated at runtime. Since the given block is evaluated on the record instance, so you can refer to other methods:

    class Song < ActiveRecord::Base

      validates_numericality_of :year

      assignable_values_for :genre do
        genres = []
        genres << 'jazz' if year > 1900
        genres << 'rock' if year > 1960
        genres
      end

    end


Obtaining assignable values from another source
-----------------------------------------------

The list of assignable values can be provided by any object that is accessible from your model. This is useful for authorization scenarios like [Consul](https://github.com/makandra/consul) or [CanCan](https://github.com/ryanb/cancan), where permissions are defined in a single class.

You can define the source of assignable values by setting the `:through` option to a lambda:

    class Story < ActiveRecord::Base
      assignable_values_for :state, :through => lambda { Power.current }
    end

`Power.current` must now respond to a method `assignable_story_states` or `assignable_story_states(story)` which returns an `Enumerable` of state strings:

    class Power

      cattr_accessor :current

      def initialize(role)
        @role = role
      end

      def assignable_story_states(story)
        states = ['draft', 'pending']
        states << 'accepted' if @role == :admin
        states
      end

    end

Listing and validating works the same with delegation:

    story = Story.new(:state => 'accepted')

    Power.current = Power.new(:guest)
    story.assignable_states # => ['draft', 'pending']
    story.valid? # => false

    Power.current = Power.new(:admin)
    story.assignable_states # => ['draft', 'pending', 'accepted']
    story.valid? # => true

Note that delegated validation is skipped when the delegate is `nil`. This way your model remains usable when there is no authorization context, like in batch processes or the console:

    story = Story.new(:state => 'foo')
    Power.current = nil
    story.valid? # => true

Think of this as enabling an optional authorization layer on top of your model validations, which can be switched on or off depending on the current context.

Instead of a lambda you can also use the `:through` option to name an instance method:

    class Story < ActiveRecord::Base
      attr_accessor :power
      assignable_values_for :state, :through => :power
    end


### Obtaining assignable values from a Consul power

A common use case for the `:through` option is when there is some globally accessible object that knows about permissions for the current request. In practice you will find that it requires some effort to make sure such an object is properly instantiated and accessible.

If you are using [Consul](https://github.com/makandra/consul), you will get a lot of this plumbing for free. Consul gives you a macro `current_power` to instantiate a so called "power", which describes what the current user may access:

    class ApplicationController < ActionController::Base
      include Consul::Controller

      current_power do
        Power.new(current_user)
      end

    end

The code above will provide you with a helper method `current_power` for your controller and views. Everywhere else, you can simply access it from `Power.current`.

You can now delegate validation of assignable values to the current power by saying:

     class Story < ActiveRecord::Base
       authorize_values_for :state
     end

This is a shortcut for saying:

     class Story < ActiveRecord::Base
       assignable_values_for :state, :through => lambda { Power.current }
     end

Head over to the [Consul README](https://github.com/makandra/consul) for details.


Installation
------------

Put this into your `Gemfile`:

    gem 'assignable_values'

Now run `bundle install` and restart your server. Done.


Development
-----------

There are tests in `spec`. We only accept PRs with tests. To run tests:

- Install Ruby 2.1.8
- Create a local test database `assignable_values_test` in both MySQL and PostgreSQL
- Copy `spec/support/database.sample.yml` to `spec/support/database.yml` and enter your local credentials for the test database
- Install development dependencies using `bundle install`
- Run tests using `bundle exec rspec`

We recommend to test large changes against multiple versions of Ruby and multiple dependency sets. Supported combinations are configured in `.travis.yml`. We provide some rake tasks to help with this:

- Install development dependencies using `bundle matrix:install`
- Run tests using `bundle matrix:spec`

Note that we have configured Travis CI to automatically run tests in all supported Ruby versions and dependency sets after each push. We will only merge pull requests after a green Travis build.

I'm very eager to keep this gem leightweight and on topic. If you're unsure whether a change would make it into the gem, [talk to me beforehand](mailto:henning.koch@makandra.de).


Credits
-------

[Henning Koch](mailto:henning.koch@makandra.de) from [makandra](http://makandra.com/).
