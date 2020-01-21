# frozen_string_literal: true

module Shellabration
  class CLI
    STATUS_SUCCESS     = 0
    STATUS_WARNING     = 1
    STATUS_ERROR       = 2

    def initialize
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
    end

    private
    def run_command(name)
      @env.run(name)
    end
  end
end

