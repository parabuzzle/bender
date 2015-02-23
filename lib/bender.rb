require 'config'

module Bender

  def self.log
    Bender::Config.instance.log
  end

  def self.nickname
    Bender::Config.instance.nickname
  end

  def self.config
    Bender::Config.instance
  end

  def self.bot
    Bender::Config.instance.bot
  end

  def self.bot=(bot)
    Bender::Config.instance.bot = bot
  end

end
