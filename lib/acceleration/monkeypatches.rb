class String
  ##
  # Convenience function for converting Ruby method names to Velocity API
  # method names by replacing underscores with dashes.
  #
  def dasherize
    downcase.gsub(/_/,'-')
  end
  ##
  # Convenience function for converting Velocity API method names to Ruby
  # method or symbol names.
  def dedasherize
    gsub(/-/, '_')
  end
end

class Symbol
  ##
  # Convenience function for converting Ruby method names to Velocity API
  # method names by replacing underscores with dashes.
  #
  def dasherize
    to_s.downcase.gsub(/_/,'-').to_sym
  end
  ##
  # Convenience function for converting Velocity API method names to Ruby
  # method or symbol names.
  def dedasherize
    to_s.gsub(/-/, '_').to_sym
  end
end

