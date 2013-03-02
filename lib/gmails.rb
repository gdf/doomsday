#!/usr/bin/env ruby
require 'bundler/setup'
require 'pony'

def email(body, subject, toList, smtpFrom)
  raise "No email body" unless body and not body.empty?
  raise "No TO list" unless toList and not toList.empty?
  raise "No FROM" unless smtpFrom and not smtpFrom.empty?

  puts "Sending mail to #{toList}..."
    Pony.mail({
      :to => toList,
      :from => smtpFrom,
      :subject => subject,
      :body => body,
      :via => :smtp,
      :via_options => {
        :address => "smtp.gmail.com",
        :port => 587,
        :enable_starttls_auto => true,
        :user_name => "gdfast",
        :password => open("#{ENV['HOME']}/.gmail-creds").read.chomp,
        :authentication => :plain,
        :domain => "localhost.localdomain"
      }
    })
end


