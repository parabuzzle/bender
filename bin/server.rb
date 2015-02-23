#!/usr/bin/env ruby

# The Bender Server
#   -- Runs the IRC bot
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2013-2015 Michael Heijmans
# License::   MIT

# Set process name
$0 = "bender"

# Load the application config
require "./config/application"

# include helpers
include Bender::Helpers

Bender.log.info "## Starting bender ##"

#write the pid file
write_pid

# initialize the irc bot
begin
  opts = spunk_options_from_config
  Bender.bot = Spunk::Bot.new(opts)
  Bender.bot.connect
  Bender.bot.authenticate
  sleep 5 # block the start for a few seconds to prevent a strange race condition in the listeners later
  connect_to_default_rooms
rescue SpunkException::BotException
  Bender.log.fatal "Couldn't establish a connection to #{opts[:hostname]}:#{opts[:port]}"
  puts "Couldn't establish a connection to #{opts[:hostname]}:#{opts[:port]}"
  exit 1
end

# setup thread handling
@stop = false
@threads = {}
Thread.abort_on_exception = true

# Start the bots
Bender.log.debug "Starting the irc listener thread"
@threads[:irc_bot] = Thread.new {
  begin
    Bender::IrcListener.start Bender.bot
  rescue => e
    $stop = true
    Bender.log.fatal "Error starting the IRC Bot! ...exiting"
  end
}

unless Bender.config.disable_http
  Bender.log.debug "Starting the http listener thread"
  @threads[:http_server] = Thread.new { Bender::HttpListener.start(Bender.bot) }
end

# setup trap handlers
[:INT, :TERM].each do |t|
  trap(t) do
    $stop = true
  end
end

# Start the main loop
loop do
  break if $stop
  sleep 0.5
end

remove_pid
Bender.log.info "Exited all threads cleanly. goodbye."
exit 0

