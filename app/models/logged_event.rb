class LoggedEvent < ActiveRecord::Base
  def self.types_of_events
      {
        0 => "DEBUG",
        1 => "INFO",
        2 => "WARN",
        3 => "ERROR",
        4 => "FATAL"
      }
  end

  # There can be only one (c) value in the set of events
  def self.mcleod_fields
    %w(ip controller action request_type processing_time response_code response_status request_url)
  end

  def logged_request
    LoggedRequest.find_by self
  end

  def this_and_higher_levels
    LoggedEvent self.level
  end

  def self.this_and_higher_levels level
    level_number = self.types_of_events.invert[level.upcase]

    levels_array = self.types_of_events.select{|key, value| key >= level_number} # => [[2, "WARN"], [3, "ERROR"], [4, "FATAL"]]
    levels_hash = {}
    levels_array.each{|item| levels_hash[item[0]] = item[1]}
    levels_hash # => {2 => "WARN", 3 => "ERROR", 4 => "FATAL"}
  end
end
