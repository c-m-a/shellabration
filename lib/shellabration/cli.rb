# frozen_string_literal: true

module Shellabration
  class CLI
    STATUS_SUCCESS     = 0
    STATUS_WARNING     = 1
    STATUS_ERROR       = 2

    def initialize
      @options = {}
    end

    # @api public
    #
    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files.
    #
    # @param args [Array<String>] command line arguments
    # @return [Integer] UNIX exit code
    def run(args = ARGV)
      @options, paths = Options.new.parse(args)
      paths.each do |f|
        if File.exist?(f)
          File.open(f).each do |l|
            puts l
          end
        else
          return STATUS_ERROR
        end
      end
      STATUS_SUCCESS
    end

    private
    def run_command(name)
      @env.run(name)
    end
  end
end

