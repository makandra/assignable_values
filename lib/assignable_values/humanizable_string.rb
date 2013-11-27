# A String that responds to #humanized.
# Earlier versions of assignable_values dependent on such an API.
class HumanizableString < String

  def initialize(string, humanization)
    super(string)
    @humanization = humanization
  end

  def humanized
    @humanization
  end

end