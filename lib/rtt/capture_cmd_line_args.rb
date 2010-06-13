#!/usr/bin/ruby -w
module Rtt
  class Command
    attr_accessor :name, :optional
    cattr_accessor :param_required
  end
  class SetProjectCommand
    @@param_required = 1
  end
  class SetClientCommand
    @@param_required = 1
  end
  class StartCommand
    @@param_required = 1
  end
  class StopCommand
    @@param_required = 0
  end
  class RenameCommand
    @@param_required = 1
  end
  class ReportCommand
    @@param_required = 1
  end

  module CmdLineInterpreter

    KEYWORDS = [ 'client', 'project', 'rename', 'start', 'stop' 'report' ]
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
        op = arguments.first.to_sym
        if KEYWORDS.include?(op)
          klazz = COMMAND_MAPPING[op]
          if (arguments.length - 1) == klazz.param_required
            command = klazz.new
            command.name = arguments[1]
            command.optional = arguments[2..-1] if arguments.length > 1
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
      case cmd.class
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
      end
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
