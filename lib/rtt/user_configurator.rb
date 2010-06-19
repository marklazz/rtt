#!/usr/bin/ruby -w
module Rtt
  module UserConfigurator

    def configure_user
      say "Please fill in your personal information"
      say "========================================"
      nickname = ask('Nickname:') { |q| q.validate = /^\w+$/ }
      first_name = ask('First name:')
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
