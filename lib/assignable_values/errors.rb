module AssignableValues
  class Error < StandardError; end
  class DelegateUnavailable < Error; end
  class NoValuesGiven < Error; end
  class NoDefault < Error; end
  class UnsupportedOption < Error; end
end
