$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'datyl/config'


# see the config.yml file in this directory

def test_config_filename
  File.join File.dirname(__FILE__), 'config.yml'
end


describe Config do

  it "should raise an error if the config file doesn't exist"  do
    lambda { Datyl::Config.new('/4fl46p8bjkdf')}.should raise_error(/can't find the specified YAML file/i)
  end

  it "should raise an error if it gets a non string file path (e.g. ENV['CONFIG_FILE'] returns nil)"  do
    lambda { Datyl::Config.new(nil)}.should raise_error(/wasn't supplied a valid YAML file/i)
  end

  it "should correctly parse a valid YAML file" do
    lambda { Datyl::Config.new(test_config_filename, :silos)}.should_not raise_error
  end

  it "should raise an error if no sections are specified" do
    lambda { Datyl::Config.new(test_config_filename)}.should raise_error
  end

  it "should raise an error if a non-existant section specified" do
    lambda { Datyl::Config.new(test_config_filename, :foobar)}.should raise_error(/setup could not find a section named/i)
  end

  it "should raise an error if a section variable is nil-valued" do
    lambda { Datyl::Config.new(test_config_filename, nil) }.should raise_error(/found a section name of class NilClass/)
  end

  it "should not raise an error if a section is empty" do
    lambda { Datyl::Config.new(test_config_filename, :daitss)}.should_not raise_error
  end

  it "should properly find all the keys froma particular section, when the section is named by a string" do
    conf = Datyl::Config.new(test_config_filename, 'silos')
    conf.temp_dir_env.should == '/var/daitss/'
    conf.silo_connection_string.should == 'postgres://silo:mysecret@localhost/test_store_db'
  end

  it "should properly find the keys froma particular section, when the section is named by a FQDN" do
    conf = Datyl::Config.new(test_config_filename, 'store-master.fcla.edu')
    conf.required_pools.should == 2
  end


  it "should properly find all the keys from a particular section, when the section is named by a symbol (programmer styling points)" do
    conf = Datyl::Config.new(test_config_filename, :silos)
    conf.temp_dir_env.should == '/var/daitss/'
    conf.silo_connection_string.should == 'postgres://silo:mysecret@localhost/test_store_db'
  end

  it "should allow methods or array notation for included keys" do
    conf = Datyl::Config.new(test_config_filename, :silos)
    conf.temp_dir_env.should == conf['temp_dir_env']
    conf.silo_connection_string.should == conf['silo_connection_string']
  end

  it "should list all included keys from a configuration" do
    conf = Datyl::Config.new(test_config_filename, :database)
    conf.keys.sort.should == ['daitss_connection_string', 'silo_connection_string', 'storemaster_connection_string' ]
  end

  it "should list all values from a configuration" do
    conf = Datyl::Config.new(test_config_filename, :database)
    conf.values.sort.should == [ 'postgres://daitss:topsecret@localhost/daitss_db', 'postgres://silo:topsecret@localhost/store_db', 'postgres://storemaster:topsecret@localhost/daitss_db' ]
  end

  it "should only find the keys from the specified section, and no more" do
    conf = Datyl::Config.new(test_config_filename, :silos)
    conf.keys.length == 2
    conf.keys.include?('temp_dir_env').should == true
    conf.keys.include?('silo_connection_string').should == true
  end

  it "should get the value of the last instance of multiply defined variables when a section repeats them" do
    conf = Datyl::Config.new(test_config_filename, :silos, :database)
    conf.silo_connection_string.should == 'postgres://silo:topsecret@localhost/store_db'
    conf = Datyl::Config.new(test_config_filename, :database, :silos)
    conf.silo_connection_string.should == 'postgres://silo:mysecret@localhost/test_store_db'
  end
  
  it "should work for funky section and variable names" do   
    lambda { Datyl::Config.new(test_config_filename, 'funky-section') }.should_not raise_error
    
    conf = Datyl::Config.new(test_config_filename, 'funky-section')
    conf['funky-key'].should == 'funky value'
  end

  it "should allow us to iterate over configuration variables" do    
    conf = Datyl::Config.new(test_config_filename, :fixity)
    what_is        = {}
    what_should_be = {  'expiration_days' =>  45,  'stale_days' =>  60 }
    conf.each { |k, v| what_is[k] = v }
    what_is.should == what_should_be
  end

  it "should raise error if an object method iscalled with arguments" do
    conf = Datyl::Config.new(test_config_filename, :fixity)
    lambda { conf.expiration_days(10)  }.should raise_error(/method expiration_days takes no arguments, but got 1/)
  end


end
