#!/usr/bin/ruby -w
module Rtt
  class Project
    include DataMapper::Resource

    DEFAULT_NAME = 'default'
    DEFAULT_DESCRIPTION = 'Default Project'

    property :id, Serial
    property :name, String, :required => true, :unique => true, :default => DEFAULT_NAME
    property :description, String, :default => DEFAULT_DESCRIPTION
    property :active, Boolean, :default => false
    property :rate, Float

    has n, :tasks #, :through => Resource
    has n, :users, :through => :tasks
    belongs_to :client

    before :valid?, :set_default_client

    before :create do |project|
      project.active = true if Project.all.length == 0
      true
    end

    def self.default
      first_or_create :active => true
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
end
