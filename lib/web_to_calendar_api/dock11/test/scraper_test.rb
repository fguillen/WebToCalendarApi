require_relative "../../../../test/test_helper"
require "webmock/minitest"

class WebToCalendarApi::Dock11::ScraperTest < Minitest::Test
  def test_run
    Dir.children("#{__dir__}/fixtures").each do |filename|
      if filename == "c1_Veranstaltungen.html" # The main Calendar
        stub_request(:get, "http://www.dock11-berlin.de/index.php/cat/#{filename}").to_return(:body => File.read("#{__dir__}/fixtures/#{filename}"))
      else ## The info pages
        stub_request(:get, "http://www.dock11-berlin.de/index.php/cat/1_0/id/#{filename}").to_return(:body => File.read("#{__dir__}/fixtures/#{filename}"))
      end
    end

    result = JSON.pretty_generate WebToCalendarApi::Dock11::Scraper.run

    # File.open("#{__dir__}/fixtures/calendar.json", "w") do |f|
    #   f.write result
    # end

    assert_equal(File.read("#{__dir__}/fixtures/calendar.json"), result)
  end
end
