class LoggedEventTest < Test::Unit::TestCase
  def setup
    @logged_event = LoggedEvent.find :last
  end

  context "be able to transform itself into array of values with its value and higher values" do
    should "for low level types of messages" do
      level = "DEBUG"
      assert_equal LoggedEvent.this_and_higher_levels(level), {0 => "DEBUG", 1 => "INFO", 2 => "WARN", 3 => "ERROR", 4 => "FATAL"}
    end

    should "for middle level types of messages" do 
      level = "WARN"
      assert_equal LoggedEvent.this_and_higher_levels(level), {2 => "WARN", 3 => "ERROR", 4 => "FATAL"}
    end

    should "for high level types of messages" do
      level = "FATAL"
      assert_equal LoggedEvent.this_and_higher_levels(level), {4 => "FATAL"}
    end
  end
end
