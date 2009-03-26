class LoggedRequest
  attr_reader :events
  
  def initialize events
    @events = events
  end



  # There can be only one (c) value in the set of events
  LoggedEvent.mcleod_fields.each do |field_name|
    define_method(field_name) do
      @events.select{|event| event.send(field_name).present?}.first.send(field_name)
    end
  end



  # Time of the Request is the latest time from all events in it
  def created_at
    self.events.map{|e| e.created_at}.max
  end

  def updated_at
    self.events.map{|e| e.updated_at}.max
  end



  # Level of request is the common status of request. For example, INFO or FATAL.
  def level
    @events.max_by{|event| LoggedEvent.types_of_events.invert[event.level]}.level
  end

  def level_number
    LoggedEvent.types_of_events.invert[self.level]
  end



  def self.find_by_event logged_event
    start_event = LoggedEvent.find :last, :conditions => ['id <= ? AND content_type = \'processing\'', logged_event.id]
    start_event_of_next_request = LoggedEvent.find :first, :conditions => ['id > ? AND content_type = \'processing\'', logged_event.id]

    events = if start_event_of_next_request.present?
               LoggedEvent.find :all, :conditions => ['id >= ? AND id < ?', start_event.id, start_event_of_next_request.id]
             else #last LoggedRequest was requested
               LoggedEvent.find :all, :conditions => ['id >= ?', start_event.id]
             end
    
    events.empty? ? nil : LoggedRequest.new(events)
  end



  # General function for looking latest LoggedRequests
  # LoggedRequest.during_last 10.minutes, {:action => 'index'}
  def self.during_last dt, where = {}
    level_names = where.delete(:level)

    if where.empty? && level_names.blank? # No additional limitations so lets find all types of requests
      events = LoggedEvent.find :all, :conditions => ['created_at > ?', dt.ago]
    elsif level_names.blank?
      events = LoggedEvent.find :all, :conditions => [where.map{|key, value| "#{key} = '#{value}'"}.join(" AND ") + ' AND created_at > ?', dt.ago]
    elsif where.empty?
      events = LoggedEvent.find :all, :conditions => ['created_at > ? AND level IN (?)', dt.ago, level_names]
    else
      events = LoggedEvent.find :all, :conditions => [where.map{|key, value| "#{key} = '#{value}'"}.join(" AND ") + ' AND created_at > ? AND level IN (?)', dt.ago, level_names]
    end

    events.map{|event| self.find_by_event event}.uniq
  end



  # Some sugar...
  # LoggedRequest.errors_during_last 10.minutes
  # or
  # LoggedRequest.percent_of_warn_during_last 2.days (hint: all FATALs and ERRORs are counted as WARNINGS)
  # or
  # LoggedRequest.latest_error
  class << self
    LoggedEvent.types_of_events.values.each do |level|
      define_method(level.downcase + "s_during_last") do |dt|
        LoggedRequest.during_last dt, {:level => LoggedEvent.this_and_higher_levels(level).values}
      end

      define_method("percent_of_"+level.downcase + "s_during_last") do |dt|
        all = LoggedRequest.during_last dt
        level_type = all.select{|req| LoggedEvent.this_and_higher_levels(level).keys.any?{|key| key == req.level}}
        all.empty? ? 0 : sprintf("%.3f", level_type.size.to_f/all.size).to_f
      end

      define_method("latest_"+level.downcase) do
        level_names = LoggedEvent.this_and_higher_levels(level).values
        event = LoggedEvent.find :last, :conditions => ['level IN (?)', level_names]
        event.present? ? self.find_by_event(event) : nil
      end
    end
  end



  #Few methods to get Array#uniq working. Each request has its own unique set of events
  def hash
    @events.hash
  end

  def eql?(comparee)
    self == comparee
  end

  def ==(comparee)
    self.events == comparee.events
  end  
end
