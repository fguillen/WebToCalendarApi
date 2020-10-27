require_relative "../../../../test/test_helper"
require "webmock/minitest"

class WebToCalendarApi::BWareLandenkino::ScraperTest < Minitest::Test
  def test_run
    body = File.read("#{__dir__}/fixtures/program.json")
    stub_request(:get, "https://www.kinoheld.de/ajax/getShowsForCinemas?cinemaIds[]=108&cinemaIds[]=1657&lang=en").to_return(:body => body)

    result = JSON.pretty_generate WebToCalendarApi::BWareLandenkino::Scraper.run

    # puts "Warning: writing fixture!"
    # File.open("#{__dir__}/fixtures/calendar.json", "w") do |f|
    #   f.write result
    # end

    assert_equal(File.read("#{__dir__}/fixtures/calendar.json"), result)
  end
end
