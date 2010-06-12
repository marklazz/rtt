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

    has n, :tasks #, :through => Resource
    has n, :users, :through => :tasks
    belongs_to :client

    before :valid?, :set_default_client

    def self.default
      first_or_create :active => true
    end

    def activate_with_client(client)
      self.client = client
      self.active = true
      self.save
      self
    end

    def set_default_client
      self.client = Client.default if self.client.nil?
    end
  end
end
