##
# Monkeypatches on String to provide convenience methods
#
# _Warning:_ these could go away at any time, so do not rely on their continued
# existence. They should only be used internally within the Acceleration gem.
class String
  ##
  # Convenience function for converting Ruby method names to Velocity API
  # method names by replacing underscores with dashes.
  #
  def dasherize
    downcase.tr('_', '-')
  end

  ##
  # Convenience function for converting Velocity API method names to Ruby
  # method or symbol names.
  def dedasherize
    tr('-', '_')
  end
end

##
# Monkeypatches on Symbol to provide convenience methods
#
# _Warning:_ these could go away at any time, so do not rely on their continued
# existence. They should only be used internally within the Acceleration gem.
class Symbol
  ##
  # Convenience function for converting Ruby method names to Velocity API
  # method names by replacing underscores with dashes.
  #
  def dasherize
    to_s.downcase.tr('_', '-').to_sym
  end

  ##
  # Convenience function for converting Velocity API method names to Ruby
  # method or symbol names.
  def dedasherize
    to_s.tr('-', '_').to_sym
  end
end
