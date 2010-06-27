#!/usr/bin/ruby -w
module Rtt
  module InteractiveConfigurator

    def configure_client(name = nil)
      say "Please fill in your Client information"
      say "======================================"
      client = if name.blank?
       if (active_client = Client.first :active => true) && agree_or_enter("Want to modify current")
         active_client
       else
         modify_name_or_create_model(:client, name)
       end
      else
        modify_name_or_create_model(:client, name)
      end
      activate = !Client.current_active? || !client.active && agree_or_enter("Make this client current")
      client.description = name
      if !client.active && activate
        client.activate
      else
        client.save
      end
      client
    end

    def configure_project(name = nil, client_name = nil)
      say "Please fill in your Project information"
      say "======================================="
      project = if name.blank?
          project_name = ask_or_default('Project name', "Project name:", name, /^\w+$/)
          Project.first_or_create(:name => project_name)
        else
          modify_name_or_create_model(:project, name)
      end
      rate = ask_or_default('Project rate', "Project rate:", (project.rate if project.present?),/^[\d]+(\.[\d]+){0,1}$/)
      client_found = false
      while !client_found
        client_name=(ask("Client name:") { |q| q.validate = /^\w+$/ }) if client_name.blank?
        client = Client.first :name => client_name
        if client.blank?
          say "A Client with this name is not registered."
          create_client = agree_or_enter("Want to created a Client with that name")
          if create_client
            client = Client.create :name => client_name, :description => client_name
            client_found = true
          else
            say "Please try enter a new client name."
            client_name = nil
          end
        else
          client_found = true
        end
      end
      project.description = project.name
      project.client = client
      project.rate = rate
      project.save
      if !Project.current_active? || !project.active && agree_or_enter("Make this project (and it's client) to be the current one(s)")
        project.activate
        client.activate unless client.active
      end
      project
    end

    def configure_user(nickname = nil, skip_name = false)
      say "Please fill in your personal information"
      say "========================================"
      if !skip_name || nickname.blank? || nickname == User::DEFAULT_NICK
        nickname = ask_or_default('nickname', 'Nickname (Required):', nickname, /^\w+$/)
      end
      existing = User.first :nickname => nickname
      first_name = ask_or_default('first name', "First name:", (existing.first_name if existing.present?))
      last_name = ask_or_default('last name', 'Last name:', (existing.last_name if existing.present?))
      company = ask_or_default('company', 'Company:', (existing.company if existing.present?))
      country = ask_or_default('country', 'Country:', (existing.country if existing.present?))
      city = ask_or_default('city', 'City:', (existing.city if existing.present?))
      address = ask_or_default('address', 'Address:', (existing.address if existing.present?))
      phone = ask_or_default('phone', 'Phone:', (existing.phone if existing.present?))
      email = ask_or_default('email', 'Email:', (existing.email if existing.present?))
      site = ask_or_default('site', 'Site:', (existing.site if existing.present?))
      user_attributes = { :nickname => nickname, :first_name => first_name, :last_name => last_name, :company => company, :email => email, :address => address, :country => country, :city => city, :phone => phone, :site => site, :active => true }
      if existing.present?
        existing.attributes = user_attributes
        existing.save
        existing
      else
        User.create(user_attributes)
      end
    end

    def configure_task(name = nil, conditions = {})
      conditions.merge!(name.blank? ? { :active => true } : { :name => name })
      task = name.blank? ? Task.first(conditions) : Task.first_or_create(conditions)
      if task.present?
          say "Modify the task information (with name: #{task.name})"
          say "================================"
          name = unless agree_or_enter('Want to keep current name')
                  ask("Name:") { |q| q.validate = /^\w+$/ }
                 else
                  task.name
          end
          rate = ask_or_default('rate', "Rate:", (task.rate if task.present?), /^[\d]+(\.[\d]+){0,1}$/)
          task.rate = rate.to_f
          task.name = name
          date= ask_or_default('Date', "Date [Format: DD-MM-YYYY]:", (task.date.strftime("%d-%m-%Y") if task.present? && task.date.present?), /^\d{2,2}-\d{2,2}-\d{4,4}$/)
          task.date = Date.parse(date) if date.present? && task.date != date
          task.start_at = date
          task.end_at = date
          duration = ask_or_default('duration', "Duration:", (task.duration if task.present?), /^(\d{1,2})[hH]{1,2}(\d{1,2})[mM]{1,2}$/)
          task.duration=(duration) if duration.present?
          project_name = ask_or_default('project', 'Project name:', (task.project.name if task.present? && task.project.present?), /^\w+$/)
          task.project=(build_project_if_not_exists(project_name)) if task.project.blank? || project_name != task.project.name
          user_name = ask_or_default('user', 'User nickname:', (task.user.nickname if task.present? && task.user.present?), /^\w+$/)
          task.user=(build_user_if_not_exists(user_name)) if task.user.blank? || user_name != task.user.nickname
          task.save
          task
      else
          name.blank? ?
          say("There is no active task to configure. Please add the name of task, to this command, to modify it.") :
          say("There is no task with that name. Please check the available tasks with 'rtt list'.")
      end
    end

    private

    def agree_or_enter(text)
      response = ask("#{text} [Y (Default)/N] ?")
      response.blank? || response.downcase == 'y' || response.downcase == 'yes'
    end

    def ask_or_default(field, text, default, regexp = nil)
      return default if default.present? && regexp.present? && agree_or_enter("Want to keep the value '#{default}' for #{field}")
      value = ask(text) { |q|
          q.default = default
          q.validate=(regexp) if regexp
      }
      value.present? ? value : default
    end

    def build_client_if_not_exists(client_name)
      configure_client(client_name)
    end

    def build_project_if_not_exists(project_name)
      configure_project(project_name)
    end

    def build_user_if_not_exists(user_name)
      configure_user(user_name, true)
    end

    def modify_name_or_create_model(model_name, name)
      class_name = model_name.to_s.capitalize
      klazz = "Rtt::#{class_name}".constantize
      instance = klazz.first :name => name
      if instance.present?
        instance.name=(ask("#{class_name} name:") { |q| q.validate = /^\w+$/ }) unless agree_or_enter('Want to keep current name')
        instance.save
        instance
      else
        klazz.create :name => name
      end
    end
  end
end
