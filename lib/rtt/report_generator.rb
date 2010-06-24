#!/usr/bin/ruby -w
module Rtt
  module ReportGenerator

    attr_accessor :data, :different_fixed

    DEFAULT_FILENAME = 'rtt_report'
    FORMATS_ACCEPTED = [ :csv, :pdf ]
    REPORT_FIELDS = %w(Client Project Name Date Rate Duration)
    FIXED_FIELDS = %w(Client Project)
    REPORT_FIELD_OUTPUT = {
      'Client' => Proc.new { |task| (task.client.name) if task.client.present? },
      'Project' => Proc.new { |task| (task.project.name) if task.project.present? },
      'Name' => Proc.new { |task| task.name },
      'Date' => Proc.new { |task| task.date.strftime('%m-%d-%y') },
      'Rate' => Proc.new { |task| task.rate },
      'Duration' => Proc.new { |task| task.duration }
    }

    def column_widths(fixed_fields)
      case fixed_fields.length
        when 2
          { 0 => 360, 1 => 60, 2 => 60, 3 => 60 } # total = 540 px
        when 1
          { 0 => 80, 1 => 290, 2 => 60, 3 => 50, 4 => 60 }
        else
          { 0 => 80, 1 => 80, 2 => 210, 3 => 60, 4 => 50, 5 => 60 }
      end
    end

    def custom_user_is_defined?
      current_user.present? && current_user.nickname != Rtt::User::DEFAULT_NICK
    end

    def fill_user_information(pdf)
      pdf.cell [330, 790],
          :text => current_user.full_name_and_nickname,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
      pdf.cell [330, 770],
          :text => current_user.company,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
      pdf.cell [330, 750],
          :text => current_user.location,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
      pdf.cell [330, 730],
          :text => current_user.address,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
      pdf.cell [330, 710],
          :text => current_user.phone,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
      pdf.cell [330, 690],
          :text => current_user.email,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
      pdf.cell [330, 670],
          :text => current_user.site,
          :width => 225, :padding => 10, :border_width => 0, :align => :right
    end

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

    def full_path(output_path = nil)
      entered_filename = output_path || DEFAULT_FILENAME
      filename, directory, extension = File.basename(entered_filename), File.dirname(entered_filename), File.extname(entered_filename)
      path = directory.present? && directory != '.' && File.exists?(directory) ? directory : ENV['HOME']
      ext = extension.present? ? '' : '.pdf'
      "#{File.join(path, filename)}#{ext}"
    end

    def has_default_value?(field)
      task = self.data[:rows].first
      return true if task.nil?
      (REPORT_FIELD_OUTPUT[field].call(task) if task.present?) == eval("Rtt::#{field}::DEFAULT_NAME")
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
      filename_path = full_path(path)
      case extension
        when :pdf
          report_to_pdf filename_path
        when :csv
          raise 'CSV format report not implemented yet'
          report_to_csv path
        else
          raise 'Format not supported. Only csv and pdf are available for the moment.'
      end

    end

    private

    def amount(rate, minutes)
      rate.to_f * (minutes.to_f / 60)
    end

    def calculate_total_amount_hours_and_minutes(data)
      total_amount, total_minutes = data.inject([0, 0]) do |totals, task|
        total_a, total_m = totals
        if task[5 - fixed_fields_for_current_data.length].to_s.match(/^(\d+)h(\d+)m$/)
          minutes = $2.to_i
          minutes += ($1.to_i * 60)
          total_m += minutes
          rate = task[4 - fixed_fields_for_current_data.length]
          total_a += amount(rate, minutes)
        end
        [ total_a, total_m ]
      end
      [total_amount, total_minutes / 60, total_minutes % 60]
    end

    def extract_fixed_fields(options)
      # remove Duration as we can't filter by that
      REPORT_FIELDS[0..-2].select { |field| options.include?(field.downcase.to_sym) }
    end

    def report_to_csv output_path
      require 'fastercsv'
    rescue LoadError
      say "Missing gem: Fastercsv"
    end

     def report_to_pdf output_path
      require 'prawn'
      require 'prawn/layout'
      require "prawn/measurement_extensions"
      columns = REPORT_FIELDS - fixed_fields_for_current_data
      data = @data[:rows].map { |task| task_row_for_fields(task, columns) }
      title = ENV['title'] || ENV['TITLE'] || "RTT Report"
      total_amount, total_h, total_m = calculate_total_amount_hours_and_minutes(data)
      report_generator = self

      pdf = Prawn::Document.new(:page_layout => :portrait,
                     :left_margin => 10.mm,    # different
                     :right_margin => 1.cm,    # units
                     :top_margin => 0.1.dm,    # work
                     :bottom_margin => 0.01.m, # well
                     :page_size => 'A4') do

        report_generator.fill_user_information(self) if report_generator.custom_user_is_defined?

        move_up(140) if report_generator.custom_user_is_defined?
        font_size 16
        text(title)
        text("=" * title.length)
        move_down 10
        font_size(13)
        text("Date: #{Date.today.strftime("%m-%d-%y")}")
        font_size 16
        move_down 30

        fixed_fields = report_generator.fixed_fields_for_current_data
        fixed_fields.each do |field|
          text("#{field}: #{report_generator.fixed_value(field)}") unless report_generator.has_default_value?(field)
        end

        move_down(report_generator.custom_user_is_defined? ? 50 : 0)

        if data.present?
            table(data,
              :headers => columns,
              :position => :left,
              :border_width   => 1,
              :row_colors => [ 'fafafa', 'f0f0f0' ],
              :column_widths => report_generator.column_widths(fixed_fields),
              :font_size => 12,
              :padding => 5,
              :align => :left)
        end

        move_down 20
        text "Total time: #{total_h}h#{total_m}m"
        move_down 10
        text "Total costs: $#{sprintf('%.1f', total_amount)}"
        move_down 10

        number_pages "Page <page> / <total>", [bounds.right - 80, 0]
        say "Report saved at #{output_path}"
        render_file output_path
      end
    rescue LoadError
      say "Missing gem: prawn, prawn/layout or prawn/measurement_extensions"
    rescue => e
      say "Error while generating report: #{e.to_s}"
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
        REPORT_FIELD_OUTPUT[field].call(task) if task.present?
      end
    end
  end
end
