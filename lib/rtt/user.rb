#!/usr/bin/ruby -w
module Rtt
  class User
    include DataMapper::Resource

    DEFAULT_LOGIN = 'admin'

    property :id, Serial
    property :login, String, :required => true, :unique => true, :default => DEFAULT_LOGIN
    property :first_name, String
    property :last_name, String
    property :active, Boolean, :default => false

    has n, :tasks #, :through => Resource
    has n, :projects, :through => :tasks

    def self.default
      first_or_create :active => true
    end
  end
end
