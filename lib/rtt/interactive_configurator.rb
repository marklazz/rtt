#!/usr/bin/ruby -w
module Rtt
  module InteractiveConfigurator

    def configure_client(aclient)
      say "Please fill in your Client information"
      say "======================================"
      name = ask("Client name:")
      activate = Client.all.length == 0 || agree("Make this client current ?")
      client = aclient.present? ? aclient : Client.create(:name => name)
      client.name = name
      client.description = name
      if !cilent.active && agree("Make this client current ?")
        client.activate
      end
      client
    end

    def configure_project(aproject)
      say "Please fill in your Project information"
      say "======================================="
      project_name = ask("Project name:") { |q| q.validate = /^\w+$/ }
      rate = ask("Project rate:") { |q| q.validate = /^[\d]+(\.[\d]+){0,1}$/ }
      client_found = false
      while !client_found
        client_name = ask("Client name:") { |q| q.validate = /^\w+$/ }
        client = Client.first :name => client_name
        if client.blank?
          say "A Client withi this name is not registered."
          create_client = agree("Want to created a Client with that name? [Y/N]")
          if create_client
            client = Client.create :name => client_name, :description => client_name
            client_found = true
          else
            say "Please try enter a new client name."
          end
        else
          client_found = true
        end
      end
      project = aproject.present? ? aproject : Project.first_or_create(:name => project_name)
      project.name = project_name
      project.description = project_name
      project.client = client
      project.rate = rate
      project.save
      if !project.active && agree("Make this project current ?")
        project.activate
      end
      project
    end

    def configure_user(nickname = nil)
      say "Please fill in your personal information"
      say "========================================"
      unless nickname.present? && nickname == User::DEFAULT_NICK
        nickname = ask('Nickname (Required):') { |q| q.validate = /^\w+$/ }
      end
      first_name = ask("First name:")
      last_name = ask('Last name:')
      company = ask('Company:')
      country = ask('Country:')
      city = ask('City:')
      address = ask('Address:')
      phone = ask('Phone:')
      email = ask('Email:')
      site = ask('Site:')
      User.first_or_create :nickname => nickname, :first_name => first_name, :last_name => last_name, :company => company, :email => email, :address => address, :country => country, :city => city, :phone => phone, :site => site, :active => true
    end
  end
end
