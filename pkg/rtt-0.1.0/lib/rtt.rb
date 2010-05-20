#!/usr/bin/ruby -w
%w( rubygems spec dm-core dm-validations).each { |lib| require lib }
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'rtt', '*'))].each { |lib| require lib; }
#Dir['/home/marcelo/workspace/rtt/lib/*'].each { |lib| require lib; }

module Rtt

  VERSION = '1.0'

  extend self

  class << self

    def init(database = :rtt)
      DataMapper.setup(:default, {:adapter => "sqlite3", :database => "db/#{database.to_s}.sqlite3"})
      migrate
    end

    # Change the name of the current task.
    #
    # Usage
    #
    # chaneg_name 'new_timer_name' => Doesn't change task#start_at

    def change_name task_name
      task = current_task
      if task
        old_name = task.name
        task.name = task_name
        if task.save
          @tasks[old_name] = nil
          @tasks[task_name] = task
        end
      end
    end

    def migrate #:nodoc:
      DataMapper.auto_migrate!
    end

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
      project = Project.first_or_create :name => project_name
      project.activate_with_client(client)
    end

    # Starts a new timer. It stops the current task if there is any.
    #
    # Usage
    #
    # start a time new:
    #
    # start 'new_task'

    def start(task_name = nil)
      stop_current if current_task_present?
      task = update_task_field task_name, :start_at
      set_as_current task
      task
    end

    # Stops the current task.
    #
    def stop
      task = current_task
      if task
        update_task_field task.name, :end_at
        stop_current
      end
    end

    private

    # Implemented to help test run from clean state
    def clear
      @tasks = {}
      @clients = {}
    end

    def client(name)
      @clients = {} if @clients.nil?
      @clients[name.to_sym] ||= Client.first_or_create :name => name
    end

    def deactivate_current_project
      project = current_project
      project.active = false
      project.save
    end

    def set_as_current task
      task.active = true
      task.save
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

    def current_task_present?
      current_task
    end

    def stop_current
      task = current_task
      task.end_at = Time.now
      task.active = false
      task.save
    end

    def task name
      @tasks = {} if @tasks.nil?
      @tasks[name.to_sym] ||= Task.first_or_create :name => name
    end

    def update_task_field task_name, field_name
      name = task_name || Task::DEFAULT_NAME
      task = task(name)
      if task.__send__(field_name.to_sym).nil?
        task.__send__("#{field_name}=".to_sym, Time.now)
        task.save
      end
      task
    end
  end
end
