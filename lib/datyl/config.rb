require 'yaml'

module Datyl

  # The Config class acts a lot like a simple Struct, with named slots
  # read out of a configration file of key/value pairs. The
  # configuration file is a simple YAML file with specific named
  # sections:
  #
  #    database:
  #      daitss_connection_string: postgres://daitss:topsecret@localhost/daitss_db
  #      storemaster_connection_string: postgres://storemaster:topsecret@localhost/daitss_db
  #      silo_connection_string: postgres://silo:topsecret@localhost/store_db
  #
  #    silos:
  #      temp_dir_env: /var/daitss/
  #      silo_connection_string: postgres://silo:mysecret@localhost/test_store_db
  #
  #    daitss:
  #       ....
  #

  # Each section contains simple key/value pairs. When we create a new
  # Config object, we specify what sections we're interested in. Each
  # section is processed in the order presented to the constructor, so
  # a key that's found in multiple sections (like the key
  # silo_connection_string above) gets the value of the last key
  # encountered.

  #
  # Typically, we expect a few global sections at the top of the file
  # and specified first in the constructor.


  class Config

    def initialize yaml_path, *sections

      # We try to be very specific with our error messages here, since
      # configuration is a pain point for new installers.

      raise "Configuration setup wasn't supplied a valid YAML file path - instead it got a #{yaml_path.class}" unless yaml_path.class == String
      raise "Configuration setup can't find the specified YAML file #{yaml_path}" unless File.exists? yaml_path
      raise "Configuration setup can't read the specified YAML file #{yaml_path}" unless File.readable? yaml_path

      begin
        @yaml = YAML.load_file yaml_path
      rescue => e
        raise "Configuration setup did not correctly parse the specified YAML file #{yaml_path}: #{e.message}"
      end

      if @yaml.class != Hash
        raise "Configuration setup parsed the specified YAML file #{yaml_path}, but it's not a simple hash (it's a #{@yaml.class})"
      end

      @hash = Hash.new

      sections.each do |sect|
        data = @yaml[sect.to_s]
        if data.nil?
          raise "Configuration setup could not find a section named #{sect} in the specified YAML file #{yaml_path}"
        end
        if data.class != Hash
          raise "Configuration setup expected that the section named #{sect} from the specified YAML file #{yaml_path} would be a hash, but instead it's a #{data.class}"
        end
        data.each { |k,v|  @hash[k] = v }
      end
    end
    
    def method_missing method, *args
      if not args.empty?
        raise "${method} takes no arguments, but got #{args.length}"
      end
      return @hash[method.to_s]
    end

    def []= key, value
      @hash[key.to_s] = value
    end

    def [] key
      return @hash[key.to_s]
    end

    def keys
      @hash.keys
    end

    def values
      @hash.values
    end

    def each 
      @hash.each do |k, v|
        yield k, v
      end
    end


  end # of class Config
end # of module Datyl
