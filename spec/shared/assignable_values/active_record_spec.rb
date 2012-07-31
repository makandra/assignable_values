require 'spec_helper'
require 'ostruct'

describe AssignableValues::ActiveRecord do

  def disposable_song_class(&block)
    klass = Class.new(Song) #, &block)
    def klass.name
      'Song'
    end
    klass.class_eval(&block) if block
    klass
  end

  describe '.assignable_values' do

    it 'should raise an error when not called with a block or :through option' do
      expect do
        disposable_song_class do
          assignable_values_for :genre
        end
      end.to raise_error(AssignableValues::NoValuesGiven)
    end

    context 'when validating scalar attributes' do

      context 'without options' do

        before :each do
          @klass = disposable_song_class do
            assignable_values_for :genre do
              %w[pop rock]
            end
          end
        end

        it 'should validate that the attribute is allowed' do
          @klass.new(:genre => 'pop').should be_valid
          @klass.new(:genre => 'disallowed value').should_not be_valid
        end

        it 'should use the same error message as validates_inclusion_of' do
          record = @klass.new(:genre => 'disallowed value')
          record.valid?
          errors = record.errors[:genre]
          error = errors.is_a?(Array) ? errors.first : errors # the return value sometimes was a string, sometimes an Array in Rails
          error.should == I18n.t('errors.messages.inclusion')
          error.should == 'is not included in the list'
        end

        it 'should not allow nil for the attribute value' do
          @klass.new(:genre => nil).should_not be_valid
        end

        it 'should allow a previously saved value even if that value is no longer allowed' do
          record = @klass.create!(:genre => 'pop')
          @klass.update_all(:genre => 'disallowed value') # update without validations for the sake of this test
          record.reload.should be_valid
        end

        it 'should generate a method returning the humanized value' do
          song = @klass.new(:genre => 'pop')
          song.humanized_genre.should == 'Pop music'
        end

        it 'should generate a method returning the humanized value, which is nil when the value is blank' do
          song = @klass.new
          song.genre = nil
          song.humanized_genre.should be_nil
          song.genre = ''
          song.humanized_genre.should be_nil
        end

        it 'should generate a method to retrieve the humanization of any given value' do
          song = @klass.new(:genre => 'pop')
          song.humanized_genre('rock').should == 'Rock music'
        end

      end

      context 'if the :allow_blank option is set' do

        before :each do
          @klass = disposable_song_class do
            assignable_values_for :genre, :allow_blank => true do
              %w[pop rock]
            end
          end
        end

        it 'should allow nil for the attribute value' do
          @klass.new(:genre => nil).should be_valid
        end

        it 'should allow an empty string as value if the :allow_blank option is set' do
          @klass.new(:genre => '').should be_valid
        end

      end

    end

    context 'when validating belongs_to associations' do

      it 'should validate that the association is allowed' do
        allowed_association = Artist.create!
        disallowed_association = Artist.create!
        klass = disposable_song_class do
          assignable_values_for :artist do
            [allowed_association]
          end
        end
        klass.new(:artist => allowed_association).should be_valid
        klass.new(:artist => disallowed_association).should_not be_valid
      end

      it 'should allow a nil association if the :allow_blank option is set' do
        klass = disposable_song_class do
          assignable_values_for :artist, :allow_blank => true do
            []
          end
        end
        record = klass.new
        record.artist.should be_nil
        record.should be_valid
      end

      it 'should allow a previously saved association even if that association is no longer allowed' do
        allowed_association = Artist.create!
        disallowed_association = Artist.create!
        klass = disposable_song_class
        record = klass.create!(:artist => disallowed_association)
        klass.class_eval do
          assignable_values_for :artist do
            [allowed_association]
          end
        end
        record.should be_valid
      end

      it "should not load a previously saved association if the association's foreign key hasn't changed" do
        association = Artist.create!
        klass = disposable_song_class do
          assignable_values_for :artist do
            [association] # This example doesn't care about what's assignable. We're only interested in behavior up to the validation.
          end
        end
        record = klass.create!(:artist => association)
        Artist.should_not_receive(:find_by_id)
        record.valid?
      end

      it 'should not fail or allow nil if a previously saved association no longer exists in the database' do
        allowed_association = Artist.create!
        klass = disposable_song_class do
          assignable_values_for :artist do
            [allowed_association]
          end
        end
        record = klass.new
        record.stub :artist_id_was => -1
        record.should_not be_valid
      end

      it 'should uncache a stale association before validating' do
        klass = disposable_song_class do
          assignable_values_for :artist do
            [] # This example doesn't care about what's assignable. We're only interested in behavior up to the validation.
          end
        end
        association = Artist.create!
        record = klass.new
        record.stub(:artist => association, :artist_id => -1) # This is a stale association: The associated object's id doesn't match the foreign key. This can happen in Rails 2, not Rails 3.
        record.should_receive(:artist).ordered.and_return(association)
        record.should_receive(:artist).ordered.with(true).and_return(association)
        record.valid?
      end

      it 'should not uncache a fresh association before validating' do
        klass = disposable_song_class do
          assignable_values_for :artist do
            [] # This example doesn't care about what's assignable. We're only interested in behavior up to the validation.
          end
        end
        association = Artist.create!
        record = klass.new
        record.stub(:artist => association, :artist_id => association.id) # This is a fresh association: The associated object's id matches the foreign key.
        record.should_receive(:artist).with(no_args).and_return(association)
        record.valid?
      end

    end

    context 'when delegating using the :through option' do

      it 'should obtain allowed values from a method with the given name' do
        klass = disposable_song_class do
          assignable_values_for :genre, :through => :delegate
          def delegate
            OpenStruct.new(:assignable_song_genres => %w[pop rock])
          end
        end
        klass.new(:genre => 'pop').should be_valid
        klass.new(:genre => 'disallowed value').should_not be_valid
      end

      it 'should be able to delegate to a lambda, which is evaluated in the context of the record instance' do
        klass = disposable_song_class do
          assignable_values_for :genre, :through => lambda { delegate }
          def delegate
            OpenStruct.new(:assignable_song_genres => %w[pop rock])
          end
        end
        klass.new(:genre => 'pop').should be_valid
        klass.new(:genre => 'disallowed value').should_not be_valid
      end

      it 'should skip the validation if that method returns nil' do
        klass = disposable_song_class do
          assignable_values_for :genre, :through => :delegate
          def delegate
            nil
          end
        end
        klass.new(:genre => 'pop').should be_valid
      end

    end

    context 'with :default option' do

      it 'should allow to set a default' do
        klass = disposable_song_class do
          assignable_values_for :genre, :default => 'pop' do
            %w[pop rock]
          end
        end
        klass.new.genre.should == 'pop'
      end

      it 'should allow to set a default through a lambda' do
        klass = disposable_song_class do
          assignable_values_for :genre, :default => lambda { 'pop' } do
            %w[pop rock]
          end
        end
        klass.new.genre.should == 'pop'
      end

      it 'should evaluate a lambda default in the context of the record instance' do
        klass = disposable_song_class do
          assignable_values_for :genre, :default => lambda { default_genre } do
            %w[pop rock]
          end
          def default_genre
            'pop'
          end
        end
        klass.new.genre.should == 'pop'
      end

    end

    context 'when generating methods to list assignable values' do

      it 'should generate an instance method returning a list of assignable values' do
        klass = disposable_song_class do
          assignable_values_for :genre do
            %w[pop rock]
          end
        end
        klass.new.assignable_genres.should == %w[pop rock]
      end

      it 'should call #to_a on the list of assignable values, allowing ranges and scopes to be passed as allowed value descriptors' do
        klass = disposable_song_class do
          assignable_values_for :year do
            1999..2001
          end
        end
        klass.new.assignable_years.should == [1999, 2000, 2001]
      end

      it 'should evaluate the value block in the context of the record instance' do
        klass = disposable_song_class do
          assignable_values_for :genre do
            genres
          end
          def genres
            %w[pop rock]
          end
        end
        klass.new.assignable_genres.should == %w[pop rock]
      end

      it 'should include a previously saved value, even if is no longer allowed' do
        klass = disposable_song_class do
          assignable_values_for :genre do
            %w[pop rock]
          end
        end
        record = klass.create!(:genre => 'pop')
        klass.update_all(:genre => 'ballad') # update without validation for the sake of this test
        record.reload.assignable_genres.should =~ %w[pop rock ballad]
      end

      context 'humanization' do

        it "should define a method #humanized on strings in that list, which return up the value's' translation" do
          klass = disposable_song_class do
            assignable_values_for :genre do
              %w[pop rock]
            end
          end
          klass.new.assignable_genres.collect(&:humanized).should == ['Pop music', 'Rock music']
        end

        it 'should use String#humanize as a default translation' do
          klass = disposable_song_class do
            assignable_values_for :genre do
              %w[electronic]
            end
          end
          klass.new.assignable_genres.collect(&:humanized).should == ['Electronic']
        end

        it 'should not define a method #humanized on values that are not strings' do
          klass = disposable_song_class do
            assignable_values_for :year do
              [1999, 2000, 2001]
            end
          end
          years = klass.new.assignable_years
          years.should == [1999, 2000, 2001]
          years.first.should_not respond_to(:humanized)
        end

        it 'should allow to directly declare humanized values by passing a hash to assignable_values_for' do
          klass = disposable_song_class do
            assignable_values_for :genre do
              { 'pop' => 'Pop music', 'rock' => 'Rock music' }
            end
          end
          klass.new.assignable_genres.collect(&:humanized).should =~ ['Pop music', 'Rock music']
        end

      end

      context 'with :through option' do

        it 'should retrieve assignable values from the given method' do
          klass = disposable_song_class do
            assignable_values_for :genre, :through => :delegate
            def delegate
              @delegate ||= 'delegate'
            end
          end
          record = klass.new
          record.delegate.should_receive(:assignable_song_genres).and_return %w[pop rock]
          record.assignable_genres.should == %w[pop rock]
        end

        it "should pass the record to the given method if the delegate's query method takes an argument" do
          delegate = Object.new
          def delegate.assignable_song_genres(record)
            record_received(record)
             %w[pop rock]
          end
          klass = disposable_song_class do
            assignable_values_for :genre, :through => :delegate
            define_method :delegate do
              delegate
            end
          end
          record = klass.new
          delegate.should_receive(:record_received).with(record)
          record.assignable_genres.should ==  %w[pop rock]
        end

        it 'should raise an error if the given method returns nil' do
          klass = disposable_song_class do
            assignable_values_for :genre, :through => :delegate
            def delegate
              nil
            end
          end
          expect { klass.new.assignable_genres }.to raise_error(AssignableValues::DelegateUnavailable)
        end

      end

    end

  end

  #describe '.authorize_values_for' do
  #
  #  it 'should be a shortcut for .assignable_values_for :attribute, :through => :power' do
  #    @klass = disposable_song_class
  #    @klass.should_receive(:assignable_values_for).with(:attribute, :option => 'option', :through => :power)
  #    @klass.class_eval do
  #      authorize_values_for :attribute, :option => 'option'
  #    end
  #  end
  #
  #  it 'should generate a getter and setter for a @power field' do
  #    @klass = disposable_song_class do
  #      authorize_values_for :attribute
  #    end
  #    song = @klass.new
  #    song.should respond_to(:power)
  #    song.should respond_to(:power=)
  #  end
  #
  #end

end
