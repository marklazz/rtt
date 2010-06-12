#!/usr/bin/ruby -w
module Rtt
  module ReportGenerator

    FORMATS_ACCEPTED = [ :csv, :pdf ]
    REPORT_FIELDS = %w[Client Project Name Date Duration]
    REPORT_FIELD_OUTPUT = {
      'Client' => Proc.new { |task| task.client.name },
      'Project' => Proc.new { |task| task.project.name },
      'Name' => Proc.new { |task| task.name },
      'Date' => Proc.new { |task| task.end_at.strftime('%m-%d-%y') },
      'Duration' => Proc.new { |task| task.duration }
    }

    #
    #
    def report options = {}
      raise 'Argument must be a valid Hash. Checkout: rtt usage' unless options.is_a?(Hash) || options.keys.empty?
      extension = options.keys.select { |key| FORMATS_ACCEPTED.include?(key) }.first
      path = options[extension]
      fixed_fields = extract_fixed_fields(options)
      fixed_fields_and_values = fixed_fields.inject({}) { |hash, key| hash[key] = options[key.downcase.to_sym]; hash }
      result_set = query(options)
      case extension
        when :pdf
          report_to_pdf path, { :fixed_fields => fixed_fields_and_values, :data => result_set }
        when :csv
          raise 'CSV format report not implemented yet'
          report_to_csv path, result_set
        else
          raise 'Format not supported. Only csv and pdf are available for the moment.'
      end

    end

    private

    def extract_fixed_fields(options)
      # remove Duration as we can't filter by that
      REPORT_FIELDS[0..-2].select { |field| options.include?(field.downcase.to_sym) }
    end

    def report_to_csv output_path, result_set
      require 'fastercsv'
    rescue LoadError
      puts "Missing gem: Fastercsv"
    end

     def report_to_pdf output_path, result_set
      require 'prawn'
      require 'prawn/layout'
      require "prawn/measurement_extensions"
      fixed_fields = result_set[:fixed_fields].keys
      columns = REPORT_FIELDS - fixed_fields
      data = result_set[:data].map { |task| task_row_for_fields(task, columns) }
      5.times { data += data }

      pdf = Prawn::Document.new(:page_layout => :portrait,
      #pdf = Prawn::Document.new(:page_layout => :landscape,
                     :left_margin => 10.mm,    # different
                     :right_margin => 1.cm,    # units
                     :top_margin => 0.1.dm,    # work
                     :bottom_margin => 0.01.m, # well
                     :page_size => 'A4') do
        move_down 10
        font_size 24
        text "RTT Report"
        text "=========="
        move_down 5
        fixed_fields.each do |field|
          text "#{field}: #{result_set[:fixed_fields][field]}"
        end
        move_down 10

        table data,
          :headers => columns,
          #:position => :center,
          :position => :left,
          :border_width   => 1,
          :background_color => [ 'fafafa', 'f0f0f0' ],
          :font_size => 14,
          :padding => 5,
          :align => :left
          #:width =>  535
          #:column_widths => { 1=> 50, 2 => 40, 3 => 30}

#        cell [500,300],
          #:text => "This free flowing textbox shows how you can use Prawn's "+
            #"cells outside of a table with ease.  Think of a 'cell' as " +{:project=>{:client=>{:name=>"emex"}
            #"simply a limited purpose bounding box that is meant for laying " +
            #"out blocks of text and optionally placing a border around it",
          #:width => 225, :padding => 10, :border_width => 2


        #cell [50,75], 
          #:text => "This document demonstrates a number of Prawn's table features",
          #:border_style => :no_top, # :all, :no_bottom, :sides
          #:horizontal_padding => 5

        render_file output_path
      end
    rescue LoadError
      puts "Missing gem: prawn, prawn/layout or prawn/measurement_extensions"
    end

    def task_row_for_fields(task, fields)
      fields.map do |field|
        REPORT_FIELD_OUTPUT[field].call(task)
      end
    end
  end
end
