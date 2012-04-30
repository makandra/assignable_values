assignable_values - Enums on vitamins
=====================================

`assignable_values` lets you restrict the values that can be assigned to attributes or associations of ActiveRecord models. You can think of it as enums where the list of allowed values is generated at runtime and the value is checked during validation.

We carefully enhanced the cure enum functionality with small tweaks that are useful for web forms, internationalized applications and common authorization patterns.


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

When obtaining a list of assignable values, each value will have a method `#humanized` that returns the translation:

    song.assignable_genres.first           # => "pop"
    song.assignable_genres.first.humanized # => "Pop music"

You can populate a `<select>` tag with pairs of internal values and human labels like this:

    form.collection_select :genre, form.object.assignable_genres, :to_s, :humanized


### Defining default values

You can define a default value by using the `:default` option:

    class Song < ActiveRecord::Base
      assignable_values_for :genre, :default => 'rock' do
        ['pop', 'rock', 'electronic']
      end
    end

The default is applied to new records:

    Song.new.genre # => 'rock'

Defaults can be lambdas:

    class Song < ActiveRecord::Base
      assignable_values_for :genre, :default => lambda { Date.today.year } do
        1980 .. 2011
      end
    end

The lambda will be evaluated in the context of the record instance.


### Allowing blank values

By default, an attribute *must* be assigned an value. If the value of an attribute is blank, the attribute
will get a validation error.

If you would like to change this behavior and allow blank values to be valid, use the `:allow_blank` option:

    class Song < ActiveRecord::Base
      assignable_values_for :genre, :default => 'rock', :allow_blank => true do
        ['pop', 'rock', 'electronic']
      end
    end


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

    song.assignable_genres # => [2010, 2011, 2012, 1985]

Once a changed value has been saved, the previous value disappears from the list of assignable values:

    song.genre = 'pop'
    song.save!
    song.assignable_years # => [2010, 2011, 2012]
    song.year = 1985
    song.valid? # => false

This is to prevent records from becoming invalid as the list of assignable values evolves. This also prevents `<select>` menus with blank selections when opening an old record in a web form.


Restricting belongs_to associations
-----------------------------------

You can restrict `belongs_to` associations in the same manner as scalar attributes:

    class Song

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

Similiar to scalar attributes, associations are only validated when the foreign key (`artist_id` in the example) changes. Previously saved values will remain assignable until another association has been saved.


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

- Fork the repository.
- Push your changes with specs. There is a Rails 3 test application in `spec/app_root` if you need to test integration with a live Rails app.
- Send me a pull request.

I'm very eager to keep this gem leightweight and on topic. If you're unsure whether a change would make it into the gem, [talk to me beforehand](henning.koch@makandra.de).


Credits
-------

[Henning Koch](henning.koch@makandra.de) from [makandra](http://makandra.com/).
