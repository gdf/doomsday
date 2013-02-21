#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'net/smtp'

# add
# delete
# (report)

global_opts = Trollop::options do
  banner "Impending Doom(s)"
  stop_on %w(add delete report)
end

cmd = ARGV.shift || "report"
cmd_opts = case cmd 
  when "add"
    Trollop::options do
      opt :foo, "Foo"
    end
  when "delete"
    Trollop::options {}
  when "report"
    Trollop::options do
      # email?
    end
  else
    Trollop::die "Unknown command #{cmd}"
end 
  
# ...


