#!/usr/bin/ruby -w
module Rtt
  class Task
    include DataMapper::Resource

    DEFAULT_NAME = 'Default task'

    property :id, Serial
    property :name, String, :required => true, :default => DEFAULT_NAME
    property :start_at, DateTime
    property :end_at, DateTime
    property :active, Boolean, :default => false

    belongs_to :project
    has 1, :client, :through => :project
    belongs_to :user

    before :valid?, :set_default_project
    before :valid?, :set_default_user

    def duration
      end_date_or_now = self.end_at ? self.end_at : DateTime.now
      convert_to_hour_and_minutes(end_date_or_now - self.start_at)
    end

    def set_default_project
      self.project = Project.default if self.project.nil?
    end

    def set_default_user
      self.user = User.default if self.user.nil?
    end

    def stop
      split_task if span_multiple_days?
      deactivate
      self
    end

    private

    def convert_to_hour_and_minutes(dif)
      hours, mins = time_diff_in_hours_and_minutes(dif)
      "#{hours}h#{mins}m"
    end

    def deactivate
      self.end_at = DateTime.now
      self.active = false
      self.save
    end

    def save_in_between_days_split(date)
      task = self.clone
      task.start_at = date.beginning_of_day
      task.end_at = date.end_of_day
      task.save
    end

    def save_last_task_split(date)
      task = self.clone
      task.end_at = date.end_of_day
      task.save
    end

    def span_multiple_days?
      self.start_at.day != Date.today.day
    end

    def split_task
      date = Date.today - 1
      while (date != self.start_at.day)
        save_in_between_days_split(date)
        date -= 1
      end
      save_last_task_split(date)
      self.start_at = Date.today.beginning_of_day
    end

    def time_diff_in_hours_and_minutes(dif)
      Date::day_fraction_to_time(dif)
    end
  end
end
