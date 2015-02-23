require 'singleton'
require 'thread'
require 'mono_logger'

module Bender

  # The Bender config engine
  #   -- Provides a way of working with configuration
  #
  # Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
  # Copyright:: Copyright (c) 2013-2015 Michael Heijmans
  # License::   MIT
  class Config
    include Singleton
    attr_reader :config_hash

    def initialize
      @mutex = Mutex.new
      @config_hash = {}
      set_defaults
    end

    def self.configure(&block)
      yield self.instance if block_given?
      self.instance
    end

    def irc_log_level=(level)
      set(:irc_log_level, MonoLogger.const_get(level))
      if self.log
        self.log.level = self.irc_log_level
      end
    end

    def method_missing(key, *args, &block)
      if key.match(/\=/)
        set key.to_s.gsub('=', '').to_sym, args[0]
      else
        get key.to_sym
      end
    end

    private

      def set(key, value)
        @mutex.synchronize { @config_hash[key] = value }
      end

      def get(key)
        @config_hash[key]
      end

      def set_defaults
        # IRC Logging
        self.irc_log_file        = ENV['IRC_LOG_FILE']      || STDOUT
        self.irc_log_rotation    = ENV['IRC_LOG_ROTATION']  || 'weekly'
        self.irc_log_level       = ENV['IRC_LOG_LEVEL']     || :INFO

        # IRC Login
        self.username            = ENV['IRC_USERNAME']      || 'bender'
        self.fullname            = ENV['IRC_FULLNAME']      || 'Bender'
        self.nickname            = ENV['IRC_NICKNAME']      || 'bender'
        self.irc_server          = ENV['IRC_SERVER']        || 'localhost'
        self.irc_port            = ENV['IRC_PORT']          || 6667
        self.irc_token           = ENV['IRC_TOKEN']         || nil
        self.nickserv_password   = ENV['NICKSERV_PASSWORD'] || nil

        # HTTP
        self.disable_http        = ENV['DISABLE_HTTP']      || false
        self.http_log_file       = ENV['HTTP_LOG_FILE']     || '!BENDER_LOGGER'
        self.http_log_rotation   = ENV['HTTP_LOG_ROTATION'] || 'weekly'
        self.http_log_level      = ENV['HTTP_LOG_LEVEL']    || :INFO
        self.http_port           = ENV['PORT']              || 9091
        self.http_max_clients    = ENV['HTTP_MAX_CLIENTS']  || 4
        self.http_listen_address = ENV['HTTP_MAX_CLIENTS']  || '0.0.0.0'
        self.http_auth_token     = ENV['HTTP_AUTH_TOKEN']   || nil

        self.pid_file            = ENV['PID_FILE']          || './bender.pid'

        self.irc_rooms           = ENV['IRC_ROOMS']          ? ENV['IRC_ROOMS'].split(',')       : []
        self.irc_accept_invites  = ENV['IRC_ACCEPT_INVITES'] ? ENV['IRC_ACCEPT_INVITES'].to_bool : true
        self.irc_use_ssl         = ENV['IRC_USE_SSL']        ? ENV['IRC_USE_SSL'].to_bool        : false

        self.log                 = MonoLogger.new(self.irc_log_file, self.irc_log_rotation)
        self.log.level           = self.irc_log_level
      end
  end
end
