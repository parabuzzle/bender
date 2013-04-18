# Bender
# -- The IRC Bot container

require 'logger'
require 'yaml'
require 'webrick'
require 'spunk'

if SPUNK_VERSION < "0.1.0"
  # Check spunk version
  puts "Requires Spunk version 0.1.0 or greater"
  puts "Your version is #{SPUNK_VERSION}"
  exit 1
end

# Set constants
BENDER_ROOT=Dir.pwd
BENDER_VERSION = "0.0.1"
$0 = "bender"

# require libs dir
Dir["./lib/*.rb"].each {|file| require file }

# require servlets
Dir["./servlets/*.rb"].each {|file| require file }

# require parsers
Dir["./processors/*.rb"].each {|file| require file }

# include helpers
include BenderHelpers

# load config
CONFIG = YAML::load(File.open("config.yml"))

#start the logger
if CONFIG['log']['file'].match(/^STDOUT$/)
  lfile = STDOUT
else
  lfile = CONFIG['log']['file']
end
Log = Logger.new(lfile, CONFIG['log']['rotation']) 
Log.level = eval("Logger::#{CONFIG['log']['level']}")
Log.info("## Starting bender ##")

#write the pid file 
write_pid

#Set up the irc
username = CONFIG['irc']['username'] ||= "bender"
fullname = CONFIG['irc']['fullname'] ||= "bender"
nickname = CONFIG['irc']['nickname'] ||= "bender"
hostname = CONFIG['irc']['hostname'] ||="localhost"
invites_ok = CONFIG['irc']['invites_ok']
nickserv_password = CONFIG['irc']['nickserv_password'] ||= nil
port = CONFIG['irc']['port'] ||= 6667
token = CONFIG['irc']['token'] ||= nil
ssl = CONFIG['irc']['ssl'] ||= false
invite_ok = false
if invites_ok == true
  invite_ok = true
end

options = {:invite_ok=>invite_ok,:username => username,:fullname => fullname,:nickname => nickname,:nickserv_password=>nickserv_password, :hostname => hostname,:port => port,:token => token,:ssl => ssl,:logger=>Log}


# Make the bot object
begin
  @bot = Spunk::Bot.new(options)
  @bot.connect
  @bot.authenticate
rescue SpunkException::BotException
  Log.fatal "Couldn't establish a connection to #{hostname}:#{port}"
  puts "Couldn't establish a connection to #{hostname}:#{port}"
  exit 1
end

#connect to default rooms
CONFIG['irc']['rooms'].each { |room| @bot.join_room room }


# fork off irc bot if enabled
unless CONFIG['listeners']['irc'] == false
  Log.debug "Starting irc listener thread"
  irc_bot = Thread.new {sleep 2; IrcListener.start_irc_listener(@bot)}
end

# fork off web_listener if enabled
unless CONFIG['listeners']['http'] == false
  Log.debug "Starting http listner thread"
  http_listener = Thread.new {sleep 2; HttpListener.start_http_listener(@bot)}
end


# start thread and signal handlers
threads = [irc_bot, http_listener] # put threads in an array for watching
stop = false        # set stop flag (will be used for shutdown and cleanup)
trap("INT") do
  # If INT signal is caught, shutdown threads cleanly
  # set stop flag to true
  threads.each do |t|
    # loop through thread array and kill them off
    unless t.nil?
      Thread.kill(t)
    end
  end
  stop = true
end
trap("TERM") do
  # If TERM signal is caught, shutdown threads cleanly
  # set stop flag to true
  threads.each do |t|
    # loop through thread array and kill them off
    unless t.nil?
      Thread.kill(t)
    end
  end
  stop = true
end

#start the main loop
loop do 
  # loop forever!
  if stop == true
    # If stop was set to true by a signal handler
    # We start the shutdown routine
    # set wait to false
    wait = false
    threads.each do |t|
      # for each thread in the threads array
      # check to see if the thread is still running
      # Threads should have been killed by sig handlers
      unless t.nil?
        if t.alive? == true
          # if a thread is still alive
          # set the wait to true so we can loop
          # through this logic again until
          # all threads have cleanly exited
          wait = true
        end
      end
    end
    if wait == false
      # If all threads were dead then wait will be false
      Log.info("bender shutdown cleanly")
      remove_pid # clean up pid file
      exit       # exit out of this script
    end
  else
    # If stop is set to false we continue running
    # We also check to see if a thread has died
    # and restart the dead threads as needed
    unless CONFIG['listeners']['irc'] == false
      # if Irc bot is active
      unless irc_bot.alive?
        # If the Irc bot is dead
        # log that it crashed and restart it
        Log.error("irc listener looks crashed. restarting...")
        irc_bot = Thread.new {IrcListener.start_irc_listener(@bot)}
        # put the new ircbot in the array
        threads = [http_listener, irc_bot]
        # sleep for 1 second to ensure that the thread status is alive
        # and the next loop doesn't spawn another ircbot thread
        sleep 1
      end
    end
    unless CONFIG['listeners']['http'] == false
      # if http listener is active
      unless http_listener.alive?
        # If the http listener is dead
        # log that it crashed and restart it
        Log.error("http listener looks crashed. restarting...")
        irc_bot = Thread.new {HttpListener.start_http_listener(@bot)}
        # put the new http listener in the array
        threads = [http_listener, irc_bot]
        # sleep for 1 second to ensure that the thread status is alive
        # and the next loop doesn't spawn another ircbot thread
        sleep 1
      end
    end
  end
  # Sleep a half a second so that the loop doesn't consume cpu time
  sleep 0.5
end

