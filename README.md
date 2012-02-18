# assignable_values - Enums on vitamins

`assignable_values` lets you restrict the values that can be assigned to attributes or associations of ActiveRecord models. You can think of it as enums where the list of allowed values is generated at runtime and the value is checked during validation.

We carefully enhanced the cure enum functionality with small tweaks that are useful for web forms, internationalized applications and common authorization patterns.

## Restricting attributes

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

### How assignable values are generated

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

### Obtaining lists

You can ask a record for a list of values that can be assigned to attribute:

    song.assignable_genres # => ['pop', 'rock', 'electronic']

This is useful for populating &lt;select&gt; tags in web forms:

    form.select :genre, form.object.assignable_genres

### Human labels

You will often want to present internal values in a humanized form. E.g. `"pop"` should be presented as `"Pop music"`.

You can define human labels in your I18n dictionary:

    en:
      assignable_values:
        song:
          genre:
            pop: 'Pop music'
            rock: 'Rock music'
            electronic: 'Electronic music'
            
When obtaining a list of assignable values, each value will have a method `#human` that returns the translation:

    song.assignable_genres.first       # => 'pop'
    song.assignable_genres.first.human # => 'Pop music'

You can populate a &lt;select&gt; tag with pairs of internal values and human labels like this:

    form.collection_select :genre, form.object.assignable_genres, :to_s, :human

## Restricting belongs_to associations

### No caching

## Defining default values

## Obtaining assignable values from a delegate

Text here.

## Previously saved values

- Always valid
- Are listed

## Installation

Text here.

## Development

Text here.

## Credits

Text here.
