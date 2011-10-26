require 'datyl/logger'
require 'tempfile'
require 'time'


module Datyl

  # This class combines logging and an abbreviated, written report. The Logger system is assumed to have
  # been initialized (logging will be a no-op otherwise).  
  #
  # Create a reporter object by initializing with a Title and an optional Subtitle.
  # Example:
  #
  #   rep = Reporter.new 'Important Report', 'This could be very important'
  #
  #   rep.info 'This is a test.'      => Logs an info-level message:     'Important Report: This is a test.'
  #   rep.warn 'This is a warning.'   => Logs an warning-level message:  'Important Report: This is a warning.'
  #   rep.err  'This is an error.'    => Logs an error-level message:    'Important Report: This is an error.'
  #
  #   rep.write STDERR   => Produces on STDERR:
  #
  #                         Important Report: This could be very important
  #                         ==============================================
  #                         This is a test.
  #                         This is a warning.
  #                         This is an error.
  #
  # Note: the subtitle is only included in the written report;
  # info/warning/errors are distinguished only in the logs.  The Title
  # is included for each logged line: keep it short - use the Subtitle
  # to expand the heading for the written reports.  Set the class
  # attribute Reporter.max_lines_to_write to limit the number of lines
  # written in any particular report; it will print the first and last
  # lines of the report if the number of lines goes over that value
  # (intially, 1000 lines).  A blank line is added after the text of the
  # written report.
  #

  class Reporter

    @@max_lines = 2000    # will only write this many lines of text - first half, '...', second half.

    attr_reader   :title, :counter

    def initialize title, sub = nil
      @start     = Time.now
      @done      = nil
      @counter   = 0
      @title     = title
      @subtitle  = sub
      @tempfile  = Tempfile.new("report-#{title.split(/\s+/).map{ |word| word.gsub(/[^a-zA-Z0-9]/, '').downcase }.join('-')}-")
      @tempfile.unlink
    rescue => e
      Logger.error "Fatal error in Reporter module; #{e.class}: #{e.message}"
    end

    def self.max_lines_to_write
      @@max_lines
    end

    def self.max_lines_to_write= num
      @@max_lines = num
    end

    # for debugging - if you call 'done' the report will add to the
    # title its total runtime - from the creation time of the
    # constructor to the point 'done' was called

    def done
      @done = Time.now
    end

    # Support for logging messages at various severity levels; slightly abbreviated data is recorded to a playback
    # file.  Called with no arguments, just insert a blank line the playback file.

    def dolog *strs
      @counter += 1
      
      strs.each do |str|
        yield @title + ': ' + str unless str.empty?
        @tempfile.puts str
      end

      @tempfile.puts('') if strs.empty?
    end

    # Log messages using the INFO severity

    def info *strs
      dolog(*strs) { |s| Logger.info s }
    end

    # Log messages using the WARN severity

    def warn *strs
      dolog(*strs) { |s| Logger.warn s }
    end

    # Log messages using the ERR severity

    def err *strs
      dolog(*strs) { |s| Logger.err s }
    end


    def rewind
      @tempfile.rewind
    end

    # interesting? is true if anything has been reported - some reports could be empty

    def interesting?
      @counter > 0
    end

    def _top_lines
      @@max_lines / 2 + (@@max_lines.odd? ? 1 : 0)
    end

    def _bottom_lines
      @@max_lines / 2
    end

    # Cycle through everything that's been written, yielding a line;
    # if the report is large, the *middle* of the report is truncated.
    # It's meant to be used in email reports. Only a total @@max_lines
    # is provided split equally from from the the begginning and the
    # end.

    def each
      title = @title + (@subtitle ? ": #{@subtitle}" : '') +  (@done ? sprintf(" (%3.2f seconds)", @done - @start) : '')
      yield title
      yield title.gsub(/./, ':')

      @tempfile.rewind

      if @counter > @@max_lines
        yield "Note: #{@counter - @@max_lines} of #{@counter} lines were discarded - see the system log for the complete report."

        _top_lines.times  { yield @tempfile.gets }           # print first half

        @tempfile.rewind

        (@counter - _bottom_lines).times { @tempfile.gets }  # discard middle

        yield " ..."

        while not @tempfile.eof                             # print last half
          yield @tempfile.gets
        end

      else                     # we can print everything
        @tempfile.rewind
        while not @tempfile.eof
          yield @tempfile.gets
        end
      end

      yield ''
    end


    # Write the report to the provided IO object, STDOUT by default.
    # Only @@max_lines lines of text are written, split equally
    # between the beggining and end of the report, with an elipsis
    # inserted in between.

    def write io = STDOUT
      each do |line|
        io.puts line
      end
    end

    # A class version of the above which is immediately written out -
    # it's a convenience routine.

    def self.note message, io = STDOUT
      Logger.info message
      io.puts message
    end


  end # of class Reporter
end # of module Datyl 
