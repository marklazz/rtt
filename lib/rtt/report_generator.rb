#!/usr/bin/ruby -w
module Rtt
  module ReportGenerator

    attr_accessor :data, :different_fixed

    DEFAULT_FILENAME = 'rtt_report'
    FORMATS_ACCEPTED = [ :csv, :pdf ]
    REPORT_FIELDS = %w(Client Project Name Date Duration)
    FIXED_FIELDS = %w(Client Project)
    REPORT_FIELD_OUTPUT = {
      'Client' => Proc.new { |task| task.client.name },
      'Project' => Proc.new { |task| task.project.name },
      'Name' => Proc.new { |task| task.name },
      'Date' => Proc.new { |task| task.end_at.strftime('%m-%d-%y') },
      'Duration' => Proc.new { |task| task.duration }
    }

    def fixed_fields_for_current_data
      @fixed_fields_for_current_data ||= begin
        calculate_fixed_fields_based_on_data
        @data[:fixed_fields].keys + @different_fixed.keys.reject { |key| @different_fixed[key].length > 1 }
      end
    end

    def fixed_value(field)
      if @data[:fixed_fields].include? field
          @data[:fixed_fields][field]
      else
          @different_fixed[field].first
      end
    end

    #
    #
    def report options = {}
      raise 'Argument must be a valid Hash. Checkout: rtt usage' unless options.is_a?(Hash) || options.keys.empty?
      @different_fixed ||= FIXED_FIELDS.inject({}) { |result, key| result[key] = []; result }
      extension = options.keys.select { |key| FORMATS_ACCEPTED.include?(key) }.first
      path = options[extension]
      fixed_fields = extract_fixed_fields(options)
      fixed_fields_and_values = fixed_fields.inject({}) { |hash, key| hash[key] = options[key.downcase.to_sym]; hash }
      @data = { :fixed_fields => fixed_fields_and_values, :rows => query(options) }
      case extension
        when :pdf
          report_to_pdf path
        when :csv
          raise 'CSV format report not implemented yet'
          report_to_csv path
        else
          raise 'Format not supported. Only csv and pdf are available for the moment.'
      end

    end

    private

    def calculate_total_hours_and_minutes(data)
      data.inject([0, 0]) do |totals, task|
        total_h, total_m = totals
        task[4 - fixed_fields_for_current_data.length].match(/^(\d+)h(\d+)m$/)
        total_m += ($2.to_i % 60)
        total_h += ($1.to_i + $2.to_i / 60)
        [ total_h, total_m ]
      end
    end

    def extract_fixed_fields(options)
      # remove Duration as we can't filter by that
      REPORT_FIELDS[0..-2].select { |field| options.include?(field.downcase.to_sym) }
    end

    def report_to_csv output_path
      require 'fastercsv'
    rescue LoadError
      puts "Missing gem: Fastercsv"
    end

     def report_to_pdf output_path
      require 'prawn'
      require 'prawn/layout'
      require "prawn/measurement_extensions"

      columns = REPORT_FIELDS - fixed_fields_for_current_data
      
      data = @data[:rows].map { |task| task_row_for_fields(task, columns) }
      
      total_h, total_m = calculate_total_hours_and_minutes(data)
      report_generator = self

      pdf = Prawn::Document.new(:page_layout => :portrait,
                     :left_margin => 10.mm,    # different
                     :right_margin => 1.cm,    # units
                     :top_margin => 0.1.dm,    # work
                     :bottom_margin => 0.01.m, # well
                     :page_size => 'A4') do

        cell [330, 790],
          :text => report_generator.current_user.full_name_and_nickname,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
        cell [330, 770],
          :text => report_generator.current_user.company,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
        cell [330, 750],
          :text => report_generator.current_user.location,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
        cell [330, 730],
          :text => report_generator.current_user.address,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
        cell [330, 710],
          :text => report_generator.current_user.phone,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
        cell [330, 690],
          :text => report_generator.current_user.email,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
        cell [330, 670],
          :text => report_generator.current_user.site,
          :width => 225, :padding => 10, :border_width => 0, :align => :right

        move_up 140
        font_size 16
        text "RTT Report"
        text "=========="
        move_down 40


#        text report_generator.current_user.full_name_and_nickname, :align => :right
        #text report_generator.current_user.company, :align => :right
        #text report_generator.current_user.email, :align => :right
        #text report_generator.current_user.address, :align => :right
        #text report_generator.current_user.location, :align => :right
        #text report_generator.current_user.phone, :align => :right
        #text report_generator.current_user.site, :align => :right

        report_generator.fixed_fields_for_current_data.each do |field|
          text "#{field}: #{report_generator.fixed_value(field)}"
        end

        move_down 50

        table data,
          :headers => columns,
          #:position => :center,
          :position => :left,
          :border_width   => 1,
          :row_colors => [ 'fafafa', 'f0f0f0' ],
          :font_size => 12,
          :padding => 5,
          :align => :left
          #:width =>  535
          #:column_widths => { 1=> 50, 2 => 40, 3 => 30}

        move_down 20
        text "Total: #{total_h}h#{total_m}m"
        
        # footer
#        page_count.times do |i|
            #go_to_page(i+1)
            #lazy_bounding_box([bounds.right-50, bounds.bottom + 25], :width => 50) {
                #text "#{i+1} / #{page_count}"
            #}.draw
        #end
        number_pages "Page <page> / <total>", [bounds.right - 80, 0]

        render_file(output_path || DEFAULT_FILENAME)
      end
    rescue LoadError
      puts "Missing gem: prawn, prawn/layout or prawn/measurement_extensions"
    end

    def calculate_fixed_fields_based_on_data
      @data[:rows].each do |task|
        (REPORT_FIELDS - @data[:fixed_fields].keys).each do |field|
          value = REPORT_FIELD_OUTPUT[field].call(task)
          @different_fixed[field] << value if FIXED_FIELDS.include?(field) && !@different_fixed[field].include?(value)
        end
      end
    end

    def task_row_for_fields(task, fields)
      fields.map do |field|
        REPORT_FIELD_OUTPUT[field].call(task)
      end
    end
  end
end
