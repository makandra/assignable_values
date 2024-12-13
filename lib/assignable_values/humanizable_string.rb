# A String that responds to #humanized.
# Earlier versions of assignable_values dependent on such an API.
class HumanizableString < String

  def initialize(string, humanization)
    super(string)
    @humanization = humanization
  end

  def humanized
    ActiveSupport::Deprecation.new.warn("assignable_<value>.humanized is deprecated, use humanized_assignable_<value>s.humanized instead", caller)
    @humanization
  end

end
