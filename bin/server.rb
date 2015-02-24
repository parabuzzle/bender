#!/usr/bin/env ruby

# The Bender Server
#   -- Runs the IRC bot
#
# Author::    Michael Heijmans  (mailto:parabuzzle@gmail.com)
# Copyright:: Copyright (c) 2013-2015 Michael Heijmans
# License::   MIT

# Load the application config
require "./config/application"

# Set process name
Bender::Process.set_process_name

Bender.log.info "## Starting bender ##"

#write the pid file
Bender::Process.write_pid

# initialize the irc bot
begin
  opts = Bender::Spunk.options_from_config
  Bender.bot = Spunk::Bot.new(opts)
  Bender.bot.connect
  Bender.bot.authenticate
  sleep 5 # block the start for a few seconds to prevent a strange race condition in the listeners later
  Bender::Spunk.connect_to_default_rooms
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
Bender.log.debug "Starting the IRC Listener thread"
@threads[:irc_bot] = Thread.new {
  begin
    Bender::IrcListener.start Bender.bot
  rescue => e
    $stop = true
    Bender.log.fatal "Error starting the IRC Listener! ...exiting"
  end
}

unless Bender.config.disable_http
  Bender.log.debug "Starting the HTTP Listener thread"
  @threads[:http_server] = Thread.new {
    begin
      Bender::HttpListener.start Bender.bot
    rescue => e
      $stop = true
      Bender.log.fatal "Error starting the HTTP Listener! ...exiting"
    end
  }
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

@threads.each  do |name, t|
  Thread.kill t
end
sleep 2

Bender::Process.remove_pid
Bender.log.info "Exited all threads cleanly. goodbye."
exit 0

