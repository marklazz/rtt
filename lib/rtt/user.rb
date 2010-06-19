#!/usr/bin/ruby -w
module Rtt
  class User
    include DataMapper::Resource

    DEFAULT_NICK = 'admin'

    property :id, Serial
    property :nickname, String, :required => true, :unique => true, :default => DEFAULT_NICK
    property :first_name, String
    property :last_name, String
    property :company, String
    property :address, String
    property :city, String
    property :country, String
    property :email, String
    property :phone, String
    property :zip, String
    property :site, String
    property :active, Boolean, :default => false

    has n, :tasks #, :through => Resource
    has n, :projects, :through => :tasks

    def self.default
      first_or_create :active => true
    end

    def full_name
      "#{first_name} #{last_name}"
    end
  end
end
