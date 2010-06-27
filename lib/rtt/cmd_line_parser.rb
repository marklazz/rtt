#!/usr/bin/ruby -w
module Rtt
  class Command
    attr_accessor :name, :optional

    def next_optional
      optional.shift if optional.present?
    end
  end
  class ConfigureCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end
  class DeleteCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class PauseCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class SetProjectCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class SetUserCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class SetClientCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class StartCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class StopCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class RenameCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 1
  end
  class ReportCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class QueryCommand < Command
    NUMBER_OF_PARAM_REQUIRED = 0
  end
  class CommandNotFoundError < StandardError; end
  class TaskNotStartedError < StandardError; end
  class ParametersNotMatchCommandSignatureError < StandardError; end

  module CmdLineParser

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
     :user => SetUserCommand,
     :delete => DeleteCommand,
     :configure => ConfigureCommand
    }

    def capture(arguments)
      unless arguments.length == 0
        operation = arguments.shift.to_sym
        if COMMAND_MAPPING.keys.include?(operation)
          klazz = COMMAND_MAPPING[operation]
          if arguments.length >= klazz::NUMBER_OF_PARAM_REQUIRED
            command = klazz.new
            first_argument = arguments.shift
            if /^--.*$/.match(first_argument)
              command.name = nil
              command.optional = [first_argument]
            else
              command.name = first_argument
              command.optional = arguments if arguments.present?
            end
            Array(command)
          end
        elsif operation.present?
          command = StartCommand.new
          command.name = operation
          command.optional = arguments if arguments.present?
          Array(command)
        end
      else
        puts_usage
      end
    end

    def env_filters
      [ 'date', 'nickname', 'from', 'to', 'client', 'project' ].inject({}) do |filters, key|
        filters[key.to_sym] = env_variable(key) if env_variable(key).present?
        filters
      end
    end

    def env_variable(key)
      ENV[key] || ENV[key.upcase] || ENV[key.downcase]
    end

    def execute(cmds)
      cmds.each { |cmd| execute_single(cmd) }
      say "Operation(s) succeded."
    rescue => e
      handle_error(e)
    end

    def execute_single(cmd)
      case cmd
        when SetProjectCommand
          client = cmd.optional.shift if cmd.optional.present? && (/^--.*$/.match(cmd.optional.first)).blank?
          set_project(cmd.name, client)
        when SetClientCommand
          set_client(cmd.name)
        when StartCommand
          start(cmd.name)
        when RenameCommand
          rename(cmd.name)
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
          set_user(cmd.name)
        when DeleteCommand
          name = cmd.name
          options = name.present? ? env_filters.merge!(:name => name) : env_filters
          delete(options)
        when ConfigureCommand
          case cmd.name.downcase
            when 'task'
              update_task(cmd.optional, env_filters)
            when 'project'
              name = cmd.next_optional
              client = cmd.next_optional
              set_project(name, client, true)
            when 'client'
              name = cmd.next_optional
              set_client(name, true)
            when 'user'
              name = cmd.next_optional
              set_user(name, true)
            else
              raise CommandNotFoundError
          end
        else
          raise CommandNotFoundError
      end
    end

    def handle_error(e)
      case e
        when CommandNotFoundError
          return puts_usage
        when TaskNotStartedError
          say "There is no active task. Pause is not valid at this point."
      end
    end

    def puts_usage
      say('')
      File.open(File.join( File.dirname(__FILE__), '..', '..', "USAGE.txt")) do |file|
        while content = file.gets
          say content
        end
      end
      say('')
    end
  end
end
