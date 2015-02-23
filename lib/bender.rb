require 'config'

# Top level Bender module
#   -- Provides some top-level class methods for working with Bender
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2013-2015 Michael Heijmans
# License::   MIT
module Bender

  # returns the Bender log object
  def self.log
    Bender::Config.instance.log
  end

  # returns the Bot's nickname
  def self.nickname
    Bender::Config.instance.nickname
  end

  # returns the Bender::Config instance
  def self.config
    Bender::Config.instance
  end

  # returns the SpunkBot object
  def self.bot
    Bender::Config.instance.bot
  end

  # Sets the SpunkBot object
  def self.bot=(bot)
    Bender::Config.instance.bot = bot
  end

end
