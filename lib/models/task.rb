#!/usr/bin/env ruby
class Task < ActiveRecord::Base

  DEFAULT_NAME = 'Default task'

  belongs_to :project
  has_one :client, :through => :project
  belongs_to :user

  before_validation :set_default_project
  before_validation :set_default_user

  def self.task(task_name)
    base_attributes = { :name => task_name, :user_id => Rtt.current_user.id, :date => Date.today, :rate => (Rtt.current_project.rate if Rtt.current_project.present?) }
    if task_name.nil?
      existing_task = Task.where(:active => true).first
      if existing_task
        existing_task
      else
        base_attributes.merge!(:name => DEFAULT_NAME) if task_name.blank?
        Task.create(base_attributes)
      end
    elsif (existing_task = Task.where(base_attributes).where(Task.arel_table[:start_at].gt(Date.today.beginning_of_day)).first).present?
      existing_task
    else
      Task.create(base_attributes)
    end
  end

  def start
    self.start_at = DateTime.now
    self.active = true
    save
    self
  end

  def add_current_spent_time_to_accumulated_spent_time
    self.accumulated_spent_time = self.accumulated_spent_time + self.time_difference_since_start_at
  end

  def clone_task(task)
    task = self.dup
    task.id = nil
    task
  end

  def duration
    return '-' if end_at.blank?
    convert_to_hour_and_minutes(accumulated_spent_time)
  end

  def duration=(d)
    return unless !!/^(\d{1,2})[hH]{1,2}(\d{1,2})[mM]{1,2}$/.match(d)
    self.start_at = DateTime.parse('00:00:01', self.date)
    self.end_at = DateTime.parse('00:00:01', self.date).advance(:hours => $1.to_i, :minutes => $2.to_i, :seconds => 1)
    self.accumulated_spent_time = self.time_difference_since_start_at
  end

  def set_default_project
    self.project = Project.default if self.project.nil?
  end

  def set_default_user
    self.user = User.default if self.user.nil?
  end

  def stop
    split_task if span_multiple_days?
    finish
    self
  end

  def pause
    split_task if span_multiple_days?
    finish(DateTime.now, true)
    self
  end

  def time_difference_since_start_at
    end_date_or_now = self.end_at ? self.end_at : DateTime.now
    end_date_or_now.to_datetime - self.start_at.to_datetime
  end

  private

  def convert_to_hour_and_minutes(dif)
    hours, mins = time_diff_in_hours_and_minutes(dif)
    "#{hours}h#{mins}m"
  end

  def finish(end_at = DateTime.now, activation = false)
    self.end_at = end_at
    self.date = end_at.to_date
    self.add_current_spent_time_to_accumulated_spent_time
    self.active = activation
    self.save
  end

  def save_in_between_days_split(date)
    task = clone_task(self)
    task.start_at = date.beginning_of_day
    end_at = date.end_of_day.to_datetime
    task.send(:finish, end_at)
    task.save
  end

  def save_last_task_split(date)
    task = clone_task(self)
    end_at = date.end_of_day.to_datetime
    task.send(:finish, end_at)
    task.save
  end

  def span_multiple_days?
    self.start_at.day != Date.today.day
  end

  def split_task
    date = Date.today - 1
    while (date.to_datetime > self.start_at)
      save_in_between_days_split(date)
      date -= 1
    end
    save_last_task_split(date)
    self.start_at = Date.today.beginning_of_day.to_datetime
  end

  def time_diff_in_hours_and_minutes(dif)
    Date::day_fraction_to_time(dif)
  end
end
