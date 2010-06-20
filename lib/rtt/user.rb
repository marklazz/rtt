#!/usr/bin/ruby -w
module Rtt
  class User
    include DataMapper::Resource

    BLANK_FIELD = ''
    DEFAULT_NICK = 'Default user'

    property :id, Serial
    property :nickname, String, :required => true, :unique => true, :default => DEFAULT_NICK
    property :first_name, String, :default => BLANK_FIELD
    property :last_name, String, :default => BLANK_FIELD
    property :company, String, :default => BLANK_FIELD
    property :address, String, :default => BLANK_FIELD
    property :city, String, :default => BLANK_FIELD
    property :country, String, :default => BLANK_FIELD
    property :email, String, :default => BLANK_FIELD
    property :phone, String, :default => BLANK_FIELD
    property :zip, String, :default => BLANK_FIELD
    property :site, String, :default => BLANK_FIELD
    property :active, Boolean, :default => false

    has n, :tasks #, :through => Resource
    has n, :projects, :through => :tasks

    def self.default
      first_or_create :active => true
    end

    def activate
      self.active = true
      self.save
      self
    end

    def deactivate
      self.active = false
      self.save
      self
    end

    def full_name
      "#{first_name.present? ? first_name : ''} #{last_name.present? ? last_name : ''}".strip
    end

    def full_name_and_nickname
      "#{full_name.present? ? full_name : ''} #{full_name.present? ? "(#{nickname})" : nickname }".strip
    end

    def location
      "#{self.city}#{self.city.present? && self.country.present? ? ', ' : ''}#{self.country}".strip
    end
  end
end
