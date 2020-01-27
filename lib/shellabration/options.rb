# frozen_string_literal: true

require 'optparse'
require 'shellwords'

module Shellabration
  class Options
    def initialize
      @options = {}
    end

    def parse(command_line_args)
      args = args_from_file.concat(args_from_env).concat(command_line_args)
      define_options.parse!(args)

      if @options[:stdin]
        args = [@options[:stdin]]
        @options[:stdin] = $stdin.binmode.read
      end

      [@options, args]
    end

    def args_from_file
      if File.exist?('.shellabration') && !File.directory?('.shellabration')
        File.read('.shellabration').shellsplit
      else
        []
      end
    end

    def define_options
      OptionParser.new do |opts|
        opts.banner = 'Usage: shellabration [options] [file1, file2, ...]'
        add_formatting_options(opts)
        option(opts, '-s', '--stdin FILE')
      end
    end

    def add_formatting_options(opts)
      option(opts, '-f', '--format FORMATTER') do |key|
        @options[:formatters] ||= []
        @options[:formatters] << [key]
      end

      option(opts, '-o', '--out FILE') do |path|
        if @options[:formatters]
          @options[:formatters].last << path
        else
          @options[:output_path] = path
        end
      end
    end

    def long_opt_symbol(args)
      long_opt = args.find { |arg| arg.start_with?('--') }
      long_opt[2..-1].sub('[no-]', '').sub(/ .*/, '')
                     .tr('-', '_').gsub(/[\[\]]/, '').to_sym
    end

    # Sets a value in the @options hash, based on the given long option and its
    # value, in addition to calling the block if a block is given.
    def option(opts, *args)
      long_opt_symbol = long_opt_symbol(args)
      args += Array(OptionsHelp::TEXT[long_opt_symbol])
      opts.on(*args) do |arg|
        @options[long_opt_symbol] = arg
        yield arg if block_given?
      end
    end

    def args_from_env
      Shellwords.split(ENV.fetch('SHELLABRATION_OPTS', ''))
    end

    # This module contains help texts for command line options.
    module OptionsHelp
      TEXT = {
        config:                           'Specify configuration file.',
        out:                              ['Write output to a file instead of STDOUT.',
                                           'This option applies to the previously',
                                           'specified --format, or the default format',
                                           'if no format is specified.'],
        list_target_files:                'List all files Shellabration will inspect.',
        safe_auto_correct:                'Run auto-correct only when it\'s safe.',
        version:                          'Display version.',
        init:                             'Generate a .shellabration.json file in the current directory.'
      }.freeze
    end
  end
end
