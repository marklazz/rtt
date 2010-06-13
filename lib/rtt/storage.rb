#!/usr/bin/ruby -w
module Rtt
  module Storage

    def init(database = :rtt)
      DataMapper.setup(:default, {:adapter => "sqlite3", :database => "db/#{database.to_s}.sqlite3"})
#      DataMapper.setup(:default, {
        #:adapter => 'mysql',
        #:host => 'localhost',
        #:username => 'root',
        #:password => 'root',
        #:database => 'rtt'
      #})
      #DataObjects::Mysql.logger = DataObjects::Logger.new('log/dm.log', 0)
      migrate unless missing_tables
      DataObjects::Sqlite3.logger = DataMapper::Logger.new(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'log', 'sqlite3.log')), 0)
    end

    def migrate #:nodoc:
      DataMapper.auto_migrate!
    end

    def missing_tables
      %W(rtt_projects rtt_users rtt_clients rtt_tasks).reject { |table| DataMapper.repository.storage_exists?(table) }.empty?
    end
  end
end