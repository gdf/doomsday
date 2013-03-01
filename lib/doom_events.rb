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
    nextId = @events.size + 1
    while @events.has_key?(nextId.to_s)
      nextId += 1
    end 
    @events[nextId.to_s] = event
    save
  end

end

