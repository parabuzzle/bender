# Adds some needed methods to String objects
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2013-2015 Michael Heijmans
# License::   MIT
class String

  # Capitalizes the first letter of the string and returns a new string
  def capitalize_first_letter
      self[0].chr.capitalize + self[1, size]
  end

  # Capitalizes the first letter of the string in place
  def capitalize_first_letter!
    unless self[0] == (c = self[0,1].upcase[0])
      self[0] = c
      self
    end
  end

  # CamelCase's the string
  #
  # @example camelize "hello_world"
  #   "hello_world".camelize #=> "HelloWorld"
  def camelize
    a = self.split("_")
    a.each do |b|
      b.capitalize_first_letter!
    end
    return a.join("")
  end

  # Casts the string into its class constant
  #
  # @example classify "Bender" into Bender
  #   "Bender".classify #=> Bender
  def classify
    return eval(self)
  end

  # Casts boolean looking string into a Boolean object
  #
  # @example "true" to TrueClass
  #   "true".to_bool #=> true
  def to_bool
    case self
    when /^true$|^t$|^yes$|^y$|^1$/i
      return true
    when /^false$|^f$|^no$|^n$|^0$/i
      return false
    else
      raise TypeError, "'#{self}' can not be cast into a boolean"
    end
  end

end
