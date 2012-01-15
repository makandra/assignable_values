require 'spec_helper'

describe AssignableValues::ActiveRecord do

  describe '.assignable_values' do

    context 'for scalar attributes' do

      context 'validation' do

        it 'should validate that the attribute is allowed'

        it 'should allow nil for the attribute value if the :allow_blank option is set'

        it 'should allow a nil value if the :allow_blank option is set'

        it 'should allow an empty string as value if the :allow_blank option is set'

        it 'should allow a previously saved value even if that value is no longer allowed'

      end

      context 'defaults' do

        it 'should allow to set a default'

        it 'should allow to set a default through a lambda'

      end

    end

    context 'for belongs_to associations' do

      context 'validation' do

        it 'should validate that the association is allowed'

        it 'should allow a nil association if the :allow_blank option is set'

        it 'should allow a previously saved association even if that association is no longer allowed'

        it 'should not check a cached value against the list of assignable associations'

      end

      context 'defaults' do

        it 'should allow to set a default'

        it 'should allow to set a default through a lambda'

      end

    end

    context 'list assignable values' do

      it 'should generate an instance method returning a list of assignable values'

      it "should define a method #human on strings in that list, which return up the value's' translation"

      it 'should use String#humanize as a default translation'

      it 'should not define a method #human on values that are not strings'

      context 'with :from option' do

        it 'should retrieve assignable values from the given method'

        it 'should pass the record to the given method if that method takes an argument'

      end

    end

  end

end
