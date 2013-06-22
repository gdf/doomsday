#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'sinatra'
require 'chronic'
$: << File.dirname(__FILE__) + "/lib"
require 'doom_events'

set :public_folder, File.dirname(__FILE__) + "/static"
set :repo, "#{ENV['HOME']}/.doomsday"

get '/' do
  redirect 'index.html'
end

get '/events' do
  events = Events.new(settings.repo)
  events.load
  events.events.to_json
  # {251: {event: "description", "day": "1/2/2003", "time": "12:00:00", _added: "..."}}
end

post '/add' do
  request.body.rewind
  data = JSON.parse(request.body.read)
  
  edate = Chronic.parse(data['date'])
  event = {
    "event" => data['description'],
    "day" => edate.to_date.to_s,
    "time" => edate.strftime("%H:%M:%S"),
    "_added" => Time.now.to_s,
  }
  logger.info "Adding: #{event}"
  events = Events.new(settings.repo)
  events.load
  events.add(event) 
  "ok"
end

