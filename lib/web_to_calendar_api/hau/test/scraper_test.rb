require_relative "../../../../test/test_helper"
require "webmock/minitest"

class WebToCalendarApi::HAU::ScraperTest < Minitest::Test
  def test_run
    Dir.children("#{__dir__}/fixtures").each do |filename|
      body = File.read("#{__dir__}/fixtures/#{filename}")

      if filename == "spielplan.html" # The main Calendar
        stub_request(:get, "https://www.hebbel-am-ufer.de/programm/spielplan-tickets/").to_return(:body => body)
      else ## The info pages
        stub_request(:get, "https://www.hebbel-am-ufer.de/programm/spielplan-tickets/event/#{filename}").to_return(:body => body)
      end
    end

    result = JSON.pretty_generate WebToCalendarApi::HAU::Scraper.run

    # puts "result: #{result}"

    # puts "Warning: writing fixture!"
    # File.open("#{__dir__}/fixtures/calendar.json", "w") do |f|
    #   f.write result
    # end

    assert_equal(File.read("#{__dir__}/fixtures/calendar.json"), result)
  end
end
