#!/usr/bin/env ruby
require 'thread'
require File.expand_path(File.join( File.dirname(__FILE__), 'rtt', 'boot'))
%w( active_support active_record highline/import).each { |lib| require lib }
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'extensions', '*'))].each { |lib| require lib; }
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'models', '*'))].each { |lib| require lib; }
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'rtt', '*'))].each { |lib| require(lib) unless File.directory?(lib); }

module Rtt

  VERSION = '0.0.6'

  extend self

  class << self
    
    include CmdLineParser
    include QueryBuilder
    include ReportGenerator
    include Storage

    def update_task(name, conditions)
      extend(InteractiveConfigurator)
      configure_task(name, conditions)
    end

    def current_user
      active = User.where(:active => true).first
      return active if active.present?
      User.find_or_create_active
    end

    def delete(options = {})
      if current_task && options.blank?
        current_task.destroy
      else
        query(options).map(&:destroy)
      end
    end

    def set_user(nickname = nil, configure = false)
      user = if nickname.blank?
               current_user
             else
               User.where(:nickname => nickname).first
      end
      current_user.deactivate if current_user
      if user.blank? || configure
        extend(InteractiveConfigurator)
        configure_user(nickname)
      else
        user.activate
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
      say 'Task List'
      say '========='
      query(options).each do |task|
        say "Task: #{task.name} || Client: #{task.client.name} || Project: #{task.project.name} || User: #{task.user.nickname} || Elapsed time: #{task.duration} #{'[ACTIVE]' if task.active} \n"
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
    def set_client(name = nil, configure = false)
      if name.blank? || configure
        extend(InteractiveConfigurator)
        configure_client(name)
      else
        raise ParametersNotMatchCommandSignatureError if name.blank?
        deactivate_current_client if current_client
        client = client(name)
        unless client.active
          client.activate
        else
          client.save
        end
      end
    end

    def set_project(project_name = nil, client_name = nil, configure = false)
      if project_name.blank? || configure
        extend(InteractiveConfigurator)
        configure_project(project_name, client_name)
      else
        raise ParametersNotMatchCommandSignatureError if project_name.blank?
        deactivate_current_project if current_project
        client = client(client_name) unless client_name.nil?
        project = Project.find_or_create_by_name project_name
        project.client = client
        project.description = project_name
        unless project.active
          project.activate
        else
          project.save
        end
      end
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

    def current_client
      Client.where(:active => true).first
    end

    def current_project
      Project.where(:active => true).first
    end

    def current_task
      Task.where(:active => true).first
    end

    private

    def client(name)
      Client.find_or_create_by_name_and_description(name, name)
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
  end
end
