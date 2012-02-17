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

    Song.new(:genre => 'rock').valid? # true
    Song.new(:genre => 'elephant').valid? # false

The validation error message is the same as the one from `validates_inclusion_of` (`errors.messages.inclusion` in your `locale.yml`).

### Runtime

The list of assignable values is generated at runtime.

### Obtaining lists



### Human labels

.human

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
