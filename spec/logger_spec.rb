$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fileutils'
require 'datyl/logger'

def logfile
  File.join(File.dirname(__FILE__), 'test.log')
end

# see http://www.python.org/dev/peps/pep-3333/ for details; this is the basis of the rack spec

def pep333_env
  {
    'PATH_INFO'        => '/index.html',
    'REMOTE_ADDR'      => 'www.example.org',
    'REMOTE_USER'      => 'fischer',
    'REQUEST_METHOD'   => 'GET',
    'SERVER_PROTOCOL'  => 'HTTP/1.1',
    'QUERY_STRING'     => ''
  }
end


# get the last line out of the logfile

def getlog
  # logfilename = `ls  #{File.join(File.dirname(__FILE__), 'test00*.log')}`.split.sort.pop

  File.read(logfile).split("\n").pop.strip
end


describe Datyl::Logger do

  before do
    FileUtils.rm_f logfile()
    Datyl::Logger.setup('RSpec', 'localhost')
    Datyl::Logger.filename = logfile()
  end
 
  it "should allow us to create a log object which writes to file, including severity (INFO) and initialization tag" do
    logger = Datyl::Logger.new(:info, 'My Tag:')
    logger.write('test')
    getlog.should =~ /INFO My Tag: test$/
  end

  it "should include the date in the beginning of the logging output" do
    Datyl::Logger.info 'some stuff'
    getlog.should =~ /^\d\d\d\d\-\d\d\-\d\d \d\d:\d\d:\d\d/
  end

  it "should allow us to write an informational message using the info class method" do
    str = "This is some information"
    Datyl::Logger.info str
    getlog.should =~ /INFO #{str}$/
  end

  it "should allow us to write a warning message using the warn class method" do
    str = "This is a warning"
    Datyl::Logger.warn str
    getlog.should =~ /WARN #{str}$/
  end

  it "should allow us to write an error message using the err class method" do
    str = "This is an error"
    Datyl::Logger.err str
    getlog.should =~ /ERROR #{str}$/
  end

  it "should include apache styling when the proper environment is included" do
    Datyl::Logger.info "foo", pep333_env
    getlog.should =~ %r{www.example.org - fischer "GET /index.html HTTP/1.1"$}
  end
end
