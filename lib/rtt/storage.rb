#!/usr/bin/ruby -w
module Rtt
  module Storage

    DEFAULT_STORAGE_NAME = :rtt

    def export filename
      require 'fileutils'
      FileUtils.cp(File.join( File.dirname(__FILE__), '..', '..', 'db', "#{DEFAULT_STORAGE_NAME.to_s}.sqlite3"), filename)
    end

    def import filename
      require 'fileutils'
      FileUtils.cp(filename, File.join( File.dirname(__FILE__), '..', '..', 'db', "#{DEFAULT_STORAGE_NAME.to_s}.sqlite3"))
    end

    def init(database = :rtt)
      DataMapper.setup(:default, {:adapter => "sqlite3", :database => File.join( File.dirname(__FILE__), '..', '..', 'db', "#{database.to_s}.sqlite3") })
      migrate unless missing_tables
      #DataObjects::Sqlite3.logger = DataMapper::Logger.new(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'log', 'sqlite3.log')), 0)
    end

    def migrate #:nodoc:
      DataMapper.auto_migrate!
    end

    def missing_tables
      %W(rtt_projects rtt_users rtt_clients rtt_tasks).reject { |table| DataMapper.repository.storage_exists?(table) }.empty?
    end
  end
end
