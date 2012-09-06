#!/usr/bin/env ruby
require 'rubygems'
require 'active_record'
require 'logger'
require 'fileutils'
module Rtt
  module Storage

    def database_file
      File.expand_path(File.join(ENV['HOME'], '.rtt', config['database']))
    end

    def export filename
      FileUtils.cp(database_file, filename)
    end

    def import filename
      FileUtils.cp(filename, database_file)
    end

    def config(env = :production)
      @config ||= YAML::load_file(File.join(File.dirname(__FILE__), '..', '..', 'db', 'config.yml'))[env.to_s]
    end

    def init(env = :production)
      database_dir = File.dirname(database_file)
      FileUtils.mkdir_p(database_dir) unless FileTest::directory?(database_dir)
      ActiveRecord::Base.establish_connection(config(env).merge('database' => database_file))
      log_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'log'))
      Dir::mkdir(log_dir) unless FileTest::directory?(log_dir)
      ActiveRecord::Base.logger = Logger.new(File.open(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'log', 'database.log')), 'a'))
      silence_stream(STDOUT) do
        require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'db', 'schema.rb')) unless tables_exists?
      end
    end

    def tables_exists?
      %w(projects clients tasks users).any? { |t| ActiveRecord::Base.connection.tables.include?(t) }
    end
  end
end
