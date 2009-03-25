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
    levels_hash
  end
end
