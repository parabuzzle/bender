#put things here that you want common and available to all tests

# Hack F*$#ery
$LOAD_PATH.concat(["#{Dir.pwd}/", "#{Dir.pwd}/lib", "#{Dir.pwd}/processors", "#{Dir.pwd}/servlets"])
$LOAD_PATH.reverse!

# Define local lib base to override the installed version
# Without this, the installed libs will be loaded
# Thank you ruby for not providing load order... :-/ ~facepalm
$LIB_BASE_DIR = "#{Dir.pwd}"

# Require the libraries and test/unit
require 'test/unit'
require 'yaml'
require 'logger'
require 'webrick'
require 'spunk'
# require libs dir
Dir["#{$LIB_BASE_DIR}/lib/*.rb"].each {|file| require file }
# require servlets
Dir["#{$LIB_BASE_DIR}/servlets/*.rb"].each {|file| require file }
# require parsers
Dir["#{$LIB_BASE_DIR}/processors/*.rb"].each {|file| require file }

# Load config
CONFIG = YAML::load(File.open("#{$LIB_BASE_DIR}/config.yml"))

# logger const is used throught the application... 
# just dump it to /dev/null for tests.
Log = Logger.new("/dev/null")

class TestBase < Test::Unit::TestCase
  def test_spunk_version
    assert(SPUNK_VERSION > "0.1.0", "Your version of spunk is not compatible with Bender (#{SPUNK_VERSION} < 0.1.0)")
  end
end

# Gather tests and run 'em
Dir.glob('./test/test*.rb').each do|test|
 puts test
 require test
end