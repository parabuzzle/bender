require 'bender'

module Bender

  # Helpers methods for working with Spunk
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  module Spunk

    # Sets up and connects the IRC bot
    def self.connect!
      begin
        Bender.bot = ::Spunk::Bot.new(Bender::Spunk.options_from_config)
        Bender.bot.connect
        Bender.bot.authenticate
        sleep 5
        Bender::Spunk.connect_to_default_rooms
        return Bender.bot
      rescue SpunkException::BotException
        Bender.log.fatal "Couldn't establish a connection to #{opts[:hostname]}:#{opts[:port]}"
        puts "Couldn't establish a connection to #{opts[:hostname]}:#{opts[:port]}"
        exit 1
      end
    end

    # Generates the options hash from Bender::Config to pass to Spunk::Bot
    def self.options_from_config
      c = Bender::Config.instance

      { invite_ok:         c.irc_accept_invites,
        username:          c.username,
        fullname:          c.fullname,
        nickname:          c.nickname,
        nickserv_password: c.nickserv_password,
        hostname:          c.irc_server,
        port:              c.irc_port,
        token:             c.irc_token,
        ssl:               c.irc_use_ssl,
        logger:            c.log,
      }
    end

    # Connects to the default rooms in Bender::Config
    def self.connect_to_default_rooms
      c = Bender::Config.instance
      if c.bot
        c.log.info "Joining default rooms" unless c.irc_rooms.empty?

        c.irc_rooms.each { |room|
          room = '#' + room unless room.match(/^\#/)
          c.log.debug "  joining #{room}"
          c.bot.join_room room
        }
      else
        c.log.error "Cannot connect to rooms - No bot found!"
        return false
      end
      return true
    end
  end
end
