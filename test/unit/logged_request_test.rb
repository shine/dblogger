class LoggedRequestTest < Test::Unit::TestCase
  def setup
    @logged_request = LoggedRequest.find_by_event LoggedEvent.last
  end

  should "exist" do
    assert_not_nil @logged_request
  end

  should "have many events" do
    assert @logged_request.respond_to?(:events)
    assert @logged_request.events.size > 2
  end

  should "have mclead-type fields" do
    assert @logged_request.respond_to?(:ip)
    assert @logged_request.respond_to?(:processing_time)
    assert @logged_request.respond_to?(:request_url)
  end

  should "be able to find recent requests" do
    requests = LoggedRequest.during_last 1.year

    assert requests.is_a? Array
    requests.each do |r|
      assert r.is_a? LoggedRequest
    end
  end

  should "be able to find latest requests with fatal result" do
    requests = LoggedRequest.fatals_during_last 1.year

    assert requests.is_a? Array
    requests.each do |r|
      assert r.is_a? LoggedRequest
      assert_equal r.level, 'FATAL'
    end
  end

  should "be able to find percent of requests with fatal response type" do
    percent = LoggedRequest.percent_of_fatals_during_last 6.months

    assert percent.is_a? Float

    assert percent >= 0.0
    assert percent <= 1.0
  end

  should "have timestamp attributes equal to the lates event in it" do
    req = LoggedRequest.latest_info
    
    assert req.respond_to? :created_at
    assert req.respond_to? :updated_at
  end

  should "be able to find latest request by its type" do
    latest = LoggedRequest.latest_fatal

    all = LoggedRequest.fatals_during_last 1.year
    all.delete(latest)

    all.each do |request|
      assert latest.created_at > request.created_at
    end
  end
end
