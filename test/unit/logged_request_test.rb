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

  should "return 100 percent for info types of messages" do
    percent = LoggedRequest.percent_of_infos_during_last 6.months

    assert_equal 1.0, percent
  end

  should "have timestamp attributes equal to the latest event in it" do
    req = LoggedRequest.latest_info
    req_created_at = req.created_at
    req_updated_at = req.updated_at

    
    assert req.respond_to? :created_at
    req.events.each do |event|
      assert event.created_at <= req_created_at
    end


    assert req.respond_to? :updated_at
    req.events.each do |event|
      assert event.updated_at <= req_updated_at
    end
  end

  should "be able to find latest request by its type" do
    latest = LoggedRequest.latest_error

    all = LoggedRequest.errors_during_last 1.year
    all.delete(latest)
    assert all.size > 0

    all.each do |request|
      assert latest.created_at > request.created_at
    end
  end

  should "be able to find events inside by their type" do
    latest = LoggedRequest.latest_error

    assert_equal latest.event_of_type("processing"), latest.events.first
  end

  should "have params hash with all parameters passed into action" do
    parametrised_request = LoggedRequest.during_last(1.year, {:action => 'show'}).last

    assert parametrised_request.params['id'].present?
    assert parametrised_request.params['id'].to_i > 0
  end

  should "have no params for index actions" do
    index_request = LoggedRequest.during_last(1.year, {:action => 'index'}).last

    assert_nil index_request.params
  end
end
