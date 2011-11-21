require 'yaml'

module Datyl

  # The Config class acts a lot like a simple Struct, with named slots
  # read out of a configration file of key/value pairs. The
  # configuration file is a simple YAML file with specific named
  # sections.  For instance:
  #
  #    database:
  #      daitss_connection_string: postgres://daitss:topsecret@localhost/daitss_db
  #      storemaster_connection_string: postgres://storemaster:topsecret@localhost/daitss_db
  #      silo_connection_string: postgres://silo:topsecret@localhost/store_db
  #
  #    silos.example.org:
  #      temp_dir_env: /var/daitss/
  #      silo_connection_string: postgres://silo:mysecret@localhost/test_store_db
  #
  #       ....
  #
  # Each section contains simple key/value pairs. When we create a new
  # Config object, we specify what sections we're interested in. Each
  # section is processed in the order presented to the constructor, so
  # a key that's found in multiple sections (like the key
  # silo_connection_string above) gets the value of the last key
  # encountered if both the 'database' and 'silos.example.org'
  # sections are included.
  #
  # Typically, we expect a few global sections at the top of the file
  # and specified first in the constructor.

  class Config

    # Given a yaml file and a list of named sections, read each section in turn and add its key/values pairs
    # to our object.
    #
    # @param [String] yaml_path, a filepath to a YAML configuration file
    # @param [Array] sections, a list of sections, Strings, to include in our configuration object.

    def initialize yaml_path, *sections

      # We try to be very specific with our error messages here, since
      # configuration is a pain point for new installers.

      raise "Configuration setup wasn't supplied a valid YAML file path - instead it got a #{yaml_path.class}" unless yaml_path.class == String
      raise "Configuration setup can't find the specified YAML file #{yaml_path}" unless File.exists? yaml_path
      raise "Configuration setup can't read the specified YAML file #{yaml_path}" unless File.readable? yaml_path
      raise "Configuration setup must be supplied with one or more sections for the yaml file #{yaml_path}" if sections.empty?

      # handles nil value, an easy-to-make error when a missing environment variable is used for a section name:

      sections.each do |sec|
        raise "Configuration setup found a section name of class #{sec.class}, but only strings or symbols are allowed (sections arguments: #{sections.inspect})" unless [String, Symbol].include?(sec.class)
      end

      begin
        @yaml = YAML.load_file yaml_path
      rescue => e
        raise "Configuration setup did not correctly parse the specified YAML file #{yaml_path}: #{e.message}"
      end

      if @yaml.class != Hash
        raise "Configuration setup parsed the specified YAML file #{yaml_path}, but it's not the expected simple hash (it's a #{@yaml.class})"
      end

      @hash = Hash.new

      sections.each do |sect|
        sect = sect.to_s

        data = @yaml[sect]

        next if data.nil? and @yaml.keys.include? sect     # catch empty section

        if data.nil?
          raise "Configuration setup could not find a section named #{sect} in the specified YAML file #{yaml_path}"
        end

        data = @yaml[sect]
        if data.class != Hash
          raise "Configuration setup expected that the section named #{sect} from the specified YAML file #{yaml_path} would be a hash, but instead it's a #{data.class}"
        end
        data.each { |k,v|  @hash[k] = v }
      end
    end

    private

    def method_missing method, *args
      if not args.empty?
        raise "method #{method} takes no arguments, but got #{args.length}"
      end
      return @hash[method.to_s]
    end

    public


    # Look up a configuration value by key
    #
    # @param [String] key, the configuration key
    # @return [Object] the associated value

    def [] key
      return @hash[key.to_s]
    end

    # return all keys in arbitrary order
    #
    # @return [Array] a list of keys

    def keys
      @hash.keys
    end
    
    # return all values, in the same order as #keys
    #
    # @return [Array] a list of values

    def values
      @hash.values
    end

    # iterate over all defined key/value pairs

    def each
      @hash.each do |k, v|
        yield k, v
      end
    end

    # Add an accessor to a config object (e.g. to set defaults for missing keys)
    # 
    # @param [String] key, a new key for the configuration object
    # @param [Object] value, the associated value

    def []= key, value
      raise "method #{key} already exists on this configuration object" if @hash.key? key
      @hash[key.to_s] = value
    end


  end # of class Config
end # of module Datyl
