#!/ruby

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
    else
      @events = {}
    end
  end

  def save
    FileUtils.mkdir_p(@repo, :verbose => true)
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
      block.call(day, byday[day])  
    end
  end

end

