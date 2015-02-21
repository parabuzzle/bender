# For stand alone running of test
if $LIB_BASE_DIR
  @libdir = $LIB_BASE_DIR
else
  @libdir = "#{Dir.pwd}/.."
end
require 'yaml'
require 'logger'
require 'test/unit'
require "#{@libdir}/lib/bender_helpers.rb"
include BenderHelpers

Log = Logger.new("/dev/null") unless defined?(Log)
ENV['PID_FILE'] = './bender.pid.test'

class TestBenderHelpers < Test::Unit::TestCase

  def setup
    @pid_file = ENV['PID_FILE']
    if File.exist?(@pid_file)
      File.delete(@pid_file)
    end
    @mypid = bender_pid
  end

  def teardown
  end

  def test_pid_handling
    assert !File.exist?(@pid_file)        # check that there is no pid file
    assert !pid_running?(123456)          # check pid_running? returns false on a bogus pid
    assert pid_running?(@mypid)           # check if pid_running? returns true for my current running pid
    assert write_pid                      # write the pid file
    assert File.exist?(@pid_file)         # check if the pid file creation worked
    assert remove_pid                     # remove pid file
    assert !File.exist?(@pid_file)        # check that pid file was removed
  end

end
