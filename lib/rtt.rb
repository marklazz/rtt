#!/usr/bin/ruby -w
%w( rubygems dm-core dm-validations dm-migrations active_support highline/import).each { |lib| require lib }
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'rtt', '*'))].each { |lib| require lib; }

module Rtt

  VERSION = '1.0'

  extend self

  class << self
    
    include CmdLineInterpreter
    include QueryBuilder
    include ReportGenerator
    include Storage

    def current_user
      User.first :active => true
    end

    def set_user(nickname = nil)
      current_user.deactivate if current_user
      if nickname && (user = User.first(:nickname => nickname)).present?
        user.activate
      else
        extend(UserConfigurator)
        configure_user(nickname)
      end
    end

    # Change the name of the current task.
    #
    # Usage
    #
    # rename 'new_timer_name' => Doesn't change task#start_at

    def rename task_name
      task = current_task
      if task
        task.name = task_name
        task.save
      end
    end

    # Lists all entries filtered by parameters
    #
    # For example:
    #   Rtt.list :from => '2010-5-3', :to => '2010-5-20'
    #
    def list options = {}
      puts 'Task List'
      puts '========='
      query(options).each do |task|
        puts "Name: #{task.name} elapsed time: #{task.duration} #{'[ACTIVE]' if task.active}"
      end
    end


    # Used to set the client at system level.
    #
    # Usage
    #
    # pause
    def pause
      current_task.pause if current_task
    end
    
    #
    # Used to set the client at system level.
    #
    # Usage
    #
    # set_client name
    def set_client name
      deactivate_current_client if current_client
      client = client(name)
      client.activate
    end

    def set_project project_name, client_name = nil
      deactivate_current_project if current_project
      client = client(client_name) unless client_name.nil?
      project = Project.first_or_create :name => project_name, :description => project_name
      project.activate_with_client(client)
    end

    # Starts a new timer. It stops the current task if there is any.
    #
    # Usage
    #
    # start a time new:
    #
    # start 'new_task'
    # TODO: Make it start PAUSED TASKS!
    def start(task_name = nil)
      current_task.stop if current_task.present? && task_name.present?
      Task::task(task_name).start
    end

    # Stops the current task.
    #
    def stop
      current_task.stop if current_task
    end

    private

    def client(name)
      Client.first_or_create :name => name, :description => name
    end

    def deactivate_current_client
      client = current_client
      client.active = false
      client.save
    end

    def deactivate_current_project
      project = current_project
      project.active = false
      project.save
    end

    def current_client
      Client.first :active => true
    end

    def current_project
      Project.first :active => true
    end

    def current_task
      Task.first :active => true
    end
  end
end
