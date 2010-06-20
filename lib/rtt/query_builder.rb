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
      conditions = {}
      conditions[:start_at.gte] = Date.parse(options[:from]) if options[:from]
      conditions[:end_at.lte] = Date.parse(options[:to]) if options[:to]
      conditions[:project] = { :name => options[:project] } if options[:project]
      conditions.deep_merge!({ :project => { :client => { :name => options[:client] } }}) if options[:client]
      conditions
    end
  end
end
