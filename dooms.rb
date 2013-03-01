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

class Events
  def initialize(repo)
    @repo = repo
    @events = nil
  end
  def load
    fn = File.join(@repo, "events.json")
    if File.exists?(fn)
      @events = JSON.parse(open(fn).read)
    else
      @events = {}
    end
    return @events
  end
  def save
    FileUtils.mkdir_p(@repo, :verbose => true)
    fn = File.join(@repo, "events.json")
    open(fn, "w") do |f|
      f.print JSON.pretty_generate(@events)
    end 
  end
  def add(event)
    nextId = @events.size + 1
    while @events.has_key?(nextId.to_s)
      nextId += 1
    end 
    @events[nextId.to_s] = event
    save
  end
end

# add --at <date-and-maybe-time> --event <thing> [<k>:<v>]?
# edit <id>
# delete <id>
# list
# (report) --expire

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
      :event => cmd_opts[:event],
      :day => edate.to_date.to_s,
      :time => edate.strftime("%H:%M:%S"),
      :_added => Time.now.to_s,
    }
    $events.add(event)
    puts "Added:"
    pp event
    puts "ok."

  when "delete"
    Trollop::options {}
  when "list"
    # blahk
  when "report"
    Trollop::options do
      # email?
    end
  else
    Trollop::die "Unknown command #{cmd}"
  end


