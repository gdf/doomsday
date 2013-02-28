#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'net/smtp'
require 'chronic'
require 'json'

# add --at <timestamp> --event <thing> [<k>:<v>]?
# edit <id>
# delete <id>
# list
# (report) --expire

def database(repo)
  fn = File.join(repo, "events.json")
  if File.exists?(fn)
    return JSON.parse(open(fn).read)
  else
    return {}
  end
end

def save(repo, database)
  FileUtils.mkdir_p(repo, :verbose => true)
  fn = File.join(repo, "events.json")
  open(fn, "w") do |f|
    f.print database.to_json
  end 
end

global_opts = Trollop::options do
  banner "Impending Doom(s)"
  stop_on %w(add delete report)
  opt :repo, "Dir for backing file", :type => :string, :default => "#{ENV['HOME']}/.doomsday"
end

cmd = ARGV.shift || "report"
case cmd 
  when "add"
    cmd_opts = Trollop::options do
      opt :at, "Time this doom comes to pass", :short => 'a', :type => :string, :required => true
      opt :event, "Short description of this doom", :short => 'e', :type => :string, :required => true
    end
    db = database(global_opts[:repo])
    nextId = db.size + 1
    while db.has_key?(nextId.to_s)
      nextId += 1
    end 
    # no, convert @at to time and split to day and (opt) time
    db[nextId.to_s] = cmd_opts
    save(global_opts[:repo], db)
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


