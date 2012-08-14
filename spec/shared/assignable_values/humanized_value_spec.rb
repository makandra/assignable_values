require 'spec_helper'

describe AssignableValues::HumanizedValue do

  describe '#inspect' do

    it "should be a helpful description of the instance's content" do
      value = AssignableValues::HumanizedValue.new('value', 'humanization')
      value.inspect.should == '#<AssignableValues::HumanizedValue value: "value", humanized: "humanization">'
    end

  end

end

