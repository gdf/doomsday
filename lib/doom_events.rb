#!/ruby
require 'fileutils'

def days_from_now(date)
  today = Date.today
  diff = date.jd - today.jd
  if diff < 0
    "(already happend)"
  elsif diff==0
    "today"
  elsif diff==1
    "tomorrow"
  else
    "#{diff} days"
  end
end

class Events

  attr_reader :events

  def initialize(repo)
    @repo = repo
    @events = nil
  end

  def load
    fn = File.join(@repo, "events.json")
    if File.exists?(fn)
      @events = JSON.parse(open(fn).read)
      @events.each do |id,e|
        e["day"] = Date.parse(e["day"])
      end
    else
      @events = {}
    end
  end

  def save
    show_your_work = File.exists?(@repo)
    FileUtils.mkdir_p(@repo, :verbose => show_your_work)
    fn = File.join(@repo, "events.json")
    open(fn, "w") do |f|
      f.print JSON.pretty_generate(@events)
    end 
  end

  def add(event)
    raise "missing 'event'" unless event.has_key? "event"
    raise "missing 'day'" unless event.has_key? "day"
    nextId = @events.size + 1
    while @events.has_key?(nextId.to_s)
      nextId += 1
    end 
    @events[nextId.to_s] = event
    save
  end

  def events_by_day(&block)
    byday = {}
    @events.each do |id, e|
      byday[e["day"]] ||= {}
      byday[e["day"]][id] = e
    end
    byday.keys.sort.each do |day|
      dstr = "#{days_from_now(day)}: #{day.strftime('%a, %b %d')}"
      block.call(dstr, byday[day])  
    end
  end

  def delete(id)
    unless @events.has_key?(id)
      raise "No such id #{id}"
    end
    @events.delete(id)
    save
  end

  def remove_expired
    today = Date.today
    @events.delete_if do |id|
      @events[id]["day"] < today
    end
    save
  end

  def report
    r = ""
    $events.events_by_day do |day, events|
      r << "#{day}\n"
      events.each do |id, e|
        r << "  #{e['event']} (##{id})\n"
      end
      r << "\n"
    end
    return r
  end 

end

