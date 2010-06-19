#!/usr/bin/ruby -w
module Rtt
  class Command
    attr_accessor :name, :optional
  end
  class PauseCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class SetProjectCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end
  class SetUserCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 10
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
  class QueryCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class CommandNotFoundError < StandardError; end
  class TaskNotStartedError < StandardError; end

  module CmdLineInterpreter

    COMMAND_MAPPING = {
     :project => SetProjectCommand,
     :client => SetClientCommand,
     :report => ReportCommand,
     :stop => StopCommand,
     :start => StartCommand,
     :rename => RenameCommand,
     :list => QueryCommand,
     :pause => PauseCommand,
     :resume => StartCommand,
     :user => SetUserCommand
    }

    def capture(arguments)
      unless arguments.length == 0
        operation = arguments.shift.to_sym
        if COMMAND_MAPPING.keys.include?(operation)
          klazz = COMMAND_MAPPING[operation]
          if arguments.length == klazz::NUMBER_OF_PARAM_REQUIRED
            command = klazz.new
            command.name = arguments.shift
            command.optional = arguments if arguments.present?
            Array(command)
          end
        end
      end
    end

    def env_filters
      [ 'client', 'project' ].inject({}) do |filters, key|
        filters[key.to_sym] = env_variable(key) if env_variable(key).present?
        filters
      end
    end

    def env_variable(key)
      ENV[key] || ENV[key.upcase] || ENV[key.downcase]
    end

    def execute(cmds)
      cmds.each { |cmd| execute_single(cmd) }
      puts "Operation(s) succeded."
    rescue => e
      handle_error(e)
    end

    def execute_single(cmd)
      case cmd
        when SetProjectCommand
          client = cmd.optional if cmd.optional.present?
          set_project(cmd.name, client)
        when SetClientCommand
          set_client(cmd.name)
        when StartCommand
          start(cmd.name)
        when PauseCommand
          if current_task.present?
              pause
          else
            raise TaskNotStartedError
          end
        when StopCommand
          stop
        when ReportCommand
          options = env_filters.merge!(:pdf => cmd.name)
          report(options)
        when QueryCommand
          list(env_filters)
        when SetUserCommand
          set_user(cmd.name, *cmd.optional)
        else
          raise CommandNotFoundError
      end
    end

    def handle_error(e)
      case e
        when CommandNotFoundError
          return puts_usage
        when TaskNotStartedError
          puts "There is no active task. Pause is not valid at this point."
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
