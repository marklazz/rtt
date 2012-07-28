require 'rubygems'
require 'spec'
require File.expand_path('lib/rtt')

def setup_testing_env
  Rtt.init(:test)
  User.destroy_all
  Client.destroy_all
  Project.destroy_all
  Task.destroy_all
end
