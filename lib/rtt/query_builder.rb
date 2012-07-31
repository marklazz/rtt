#!/usr/bin/env ruby
module Rtt
  module QueryBuilder
    # Query among all tasks filtering based on parameters.
    # 
    #
    def query options = {}
      relation = Task.where(rtt_build_conditions(options))
      relation = relation.where(table[:date].gt(options.delete(:from))) if options[:from]
      relation = relation.where(table[:date].lt(options.delete(:to))) if options[:to]
      relation
    end

    private

    def table
      @table ||= Task.arel_table
    end

    def rtt_build_conditions options
      # default filter for today unless a date range is specified
      options[:date] = Date.today if options[:to].blank? and options[:from].blank? and options[:date].blank?
      conditions = options.reject { |k,_| k.to_s == 'from' || k.to_s == 'to' }
      conditions[:date] = options.delete(:date) if options[:date]
      conditions[:user] = { :nickname => options.delete(:nickname) } if options[:nickname]
      conditions[:project] = { :name => options.delete(:project) } if options[:project]
      conditions.deep_merge!({ :project => { :client => { :name => options.delete(:client) } }}) if options[:client]
      conditions
    end
  end
end
