#!/usr/bin/ruby -w
module Rtt
  module QueryBuilder
    # Query among all tasks filtering based on parameters.
    # 
    #
    def query options = {}
      Task.all(rtt_build_conditions(options))
    end

    private

    def rtt_build_conditions options
      conditions = options
      conditions[:date.gte] = Date.parse(options.delete(:from)) if options[:from]
      conditions[:date.lte] = Date.parse(options.delete(:to)) if options[:to]
      conditions[:date] = Date.parse(options.delete(:date)) if options[:date]
      conditions[:user] = { :nickname => options.delete(:nickname) } if options[:nickname]
      conditions[:project] = { :name => options.delete(:project) } if options[:project]
      conditions.deep_merge!({ :project => { :client => { :name => options.delete(:client) } }}) if options[:client]
      conditions
    end
  end
end
