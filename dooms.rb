#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'net/smtp'
require 'chronic'
require 'json'
require 'pp'
$: << File.dirname(__FILE__) + "/lib"
require 'doom_events'
require 'gmails'

global_opts = Trollop::options do
  banner "Impending Doom(s)"
  stop_on %w(add delete report)
  opt :repo, "Dir for backing file", :type => :string, :default => "#{ENV['HOME']}/.doomsday"
end

$events = Events.new(global_opts[:repo])
$events.load

cmd = ARGV.shift || "report"
case cmd 
  when "add"
    cmd_opts = Trollop::options do
      opt :at, "Time this doom comes to pass", :short => 'a', :type => :string, :required => true
      opt :event, "Short description of this doom", :short => 'e', :type => :string, :required => true
    end
    edate = Chronic.parse(cmd_opts[:at])
    event = {
      "event" => cmd_opts[:event],
      "day" => edate.to_date.to_s,
      "time" => edate.strftime("%H:%M:%S"),
      "_added" => Time.now.to_s,
    }
    $events.add(event)
    puts "Added:"
    pp event
    puts "ok."

  when "delete"
    id = ARGV.shift || Trollop::die("<delete> needs id")
    $events.delete(id)

  when "list"
    $events.events.each do |id, e|
      puts "[#{id}]"
      pp e
    end

  when "report"
    cmd_opts = Trollop::options do
      opt :expire, "Remove expired events (where :day is in the past)"
      opt :email, "Email to someone", :type=>:string
      opt :from, "From address", :default=>"doom-do-not-reply"
    end
    $events.remove_expired if cmd_opts[:expire]
    report = $events.report
    if cmd_opts[:email]
      email(report, "[[Impending DOOM]]", cmd_opts[:email], cmd_opts[:from])
    else
      print report 
    end 

  else
    Trollop::die "Unknown command #{cmd}"
  end


# TODO:
# - help usage for subcommads (...sucks)
# - git commit repo

