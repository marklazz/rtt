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
    has n, :projects, :through => Resource

    def self.default
      first_or_create :active => true
    end

    def activate
      self.active = true
      self.save
      self
    end
  end
end
