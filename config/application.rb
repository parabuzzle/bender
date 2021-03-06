# This is the application initializer
# All configuration and setup for Bender belongs here.
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2013-2015 Michael Heijmans
# License::   MIT

require 'bundler/setup'
require 'spunk'

require 'pry' unless ENV['BENDER_ENV'] == 'production'

# Setup load paths
dirs = %w( ./config ./lib ./servlets ./processors )
dirs.each { |i| $LOAD_PATH.unshift i }

require 'bender'

# load libararies
dirs.each do |path|
  Dir["#{path}/*.rb"].each {|file| require file }
end

Bender::Config.configure do |config|
  # override config parameters here

  ###############################################
  ## The settings you should care about
  ##
  ## NOTE: You can set these with environment variables instead of in this file
  ##       ref: Heroku Documentation for more info - https://github.com/parabuzzle/bender/wiki/Using-Bender-on-Heroku

  # Shared Token for Admin-y pages (/stats)
  # note: if this is set to nil the token requirement is skipped
  #config.http_auth_token     = 'youshouldchangethis'

  # Bot's nickname
  #config.nickname            = 'bender'

  # IRC server to connect to
  #config.irc_server          = 'chat.freenode.net'

  # A list of rooms to connect to on startup
  #config.irc_rooms           = ['#my-awesome-room']


  ###############################################
  ## IRC Bot Logging Parameters

  # IRC bot logfile
  #config.irc_log_file        = STDOUT

  # IRC bot log file rotation
  #config.irc_log_rotation    = 'weekly'

  # IRC bot log level
  #config.irc_log_level       = :INFO


  ###############################################
  ## IRC Login Parameters

  # Bot's username (used by some irc servers)
  #config.username            = 'bender'

  # Bot's full name
  #config.fullname            = 'Bender Bending Rodriguez'

  # IRC port to connect on (change this if using SSL)
  #config.irc_port            = 6667

  # IRC server token (also known as the server password)
  #config.irc_token           = nil

  # Nickserv password for the nickname
  #config.nickserv_password   = nil

  # Allow bender to accept invite requests
  #config.irc_accept_invites  = true

  # Use SSL for IRC traffic
  #config.irc_use_ssl         = false


  ###############################################
  ## HTTP Server Parameters

  # Don't boot  the HTTP server
  #config.disable_http        = false

  # Logfile to send HTTP logs (!BENDER_LOGGER sends to the config.irc_log_file)
  #config.http_log_file       = '!BENDER_LOGGER'

  # The port to run the HTTP server on
  #config.http_port           = 9091

  # Max Clients to run via Webrick
  #config.http_max_clients    = 4

  # The listen address
  #config.http_listen_address = '0.0.0.0'

  # The pid file location
  #config.pid_file            = './bender.pid'
end

