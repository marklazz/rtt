#!/usr/bin/ruby -w
module Rtt
  class Command
    attr_accessor :name, :optional
  end
  class SetProjectCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end
  class SetClientCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end
  class StartCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end
  class StopCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class RenameCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end
  class ReportCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end

  module CmdLineInterpreter

    COMMAND_MAPPING = {
     :project => SetProjectCommand,
     :client => SetClientCommand,
     :report => ReportCommand,
     :stop => StopCommand,
     :start => StartCommand,
     :rename => RenameCommand
    }

    def capture(arguments)
      if arguments.length == 0
        puts_usage
      else
        operation = arguments.shift.to_sym
        if COMMAND_MAPPING.keys.include?(operation)
          klazz = COMMAND_MAPPING[operation]
          if arguments.length == klazz::NUMBER_OF_PARAM_REQUIRED
            command = klazz.new
            command.name = operation
            command.optional = arguments[1..-1] if arguments.length > 1
            command
          else
          puts_usage
          end
        else
          puts_usage
        end
      end
    end

    def execute(cmd)
      case cmd
        when SetProjectCommand
          client = cmd.optional if cmd.optional.present?
          Rtt.set_project(cmd.name, client)
        when SetClientCommand
          Rtt.set_client(cmd.name)
        when StartCommand
          Rtt.start(cmd.name)
        when StopCommand
          Rtt.stop
        when ReportCommand
          Rtt.report(:pdf => cmd.name)
        else
          return puts_usage
      end
      puts "Operation succeded."
    end

    def puts_usage
      puts
      File.open("USAGE.txt") do |file|
        while content = file.gets
          puts content
        end
      end
      puts
    end
  end
end
