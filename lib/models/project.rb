#!/usr/bin/ruby -w
class Project < ActiveRecord::Base

  DEFAULT_NAME = 'default'
  DEFAULT_DESCRIPTION = 'Default Project'

  has_many :tasks
  has_many :users, :through => :tasks
  belongs_to :client

  before_validation :set_default_client

  before_create do |project|
    project.active = true if Project.all.length == 0
  end

  def self.default
    find_or_create_by_active true
  end

  def self.current_active?
    where(:active => true).first
  end

  def activate
    deactivate_all
    self.active = true
    self.save
    self
  end

  def deactivate_all
    Project.all.each do |project|
      if project.id != self.id
        project.active = false
        project.save
      end
    end
  end

  def set_default_client
    self.client = Client.default if self.client.nil?
  end
end
