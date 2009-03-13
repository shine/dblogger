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
end
