#!/usr/bin/env ruby
class Client < ActiveRecord::Base

  DEFAULT_NAME = 'default'
  DEFAULT_DESCRIPTION = 'Default Client'

  has_many :projects

  before_create do |client|
    client.active = true if Client.all.length == 0
  end

  def self.default
    first_or_create :active => true
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
    Client.all.each do |client|
      client.active = false
      client.save
    end
  end
end
