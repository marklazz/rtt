#!/usr/bin/ruby -w
module Rtt
  class Task
    include DataMapper::Resource

    DEFAULT_NAME = 'Default task'

    property :id, Serial
    property :name, String, :required => true, :unique => true, :default => DEFAULT_NAME
    property :time_spent, Integer
    property :start_at, DateTime
    property :end_at, DateTime
    property :active, Boolean, :default => false

    belongs_to :project
    has 1, :client, :through => :project
    belongs_to :user

    before :valid?, :set_default_project
    before :valid?, :set_default_user

    def set_default_project
      self.project = Project.default if self.project.nil?
    end

    def set_default_user
      self.user = User.default if self.user.nil?
    end
  end
end
