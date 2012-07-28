#!/usr/bin/env ruby
class User < ActiveRecord::Base

  BLANK_FIELD = ''
  DEFAULT_NICK = 'Default user'

  has_many :tasks
  has_many :projects, :through => :tasks

  def self.default
    find_or_create_by_active(true)
  end

  def self.find_or_create_active
    last_user = User.last
    if last_user.present?
      last_user.active = true
      last_user.save
      last_user
    else
      self.default
    end
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
