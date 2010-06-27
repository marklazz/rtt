#!/usr/bin/ruby -w
module Rtt
  class Client
    include DataMapper::Resource

    DEFAULT_NAME = 'default'
    DEFAULT_DESCRIPTION = 'Default Client'

    property :id, Serial
    property :name, String, :required => true, :unique => true, :default => DEFAULT_NAME
    property :description, String, :default => DEFAULT_DESCRIPTION
    property :active, Boolean, :default => false
    has n, :projects #, :through => Resource

    before :create do |client|
      client.active = true if Client.all.length == 0
      true
    end

    def self.default
      first_or_create :active => true
    end

    def self.current_active?
      first :active => true
    end

    def activate
      deactivate_all
      self.active = true
      self.save
      self
    end

    def deactivate_all
      Client.all.each do |client|
        client.active = false
        client.save
      end
    end
  end
end
