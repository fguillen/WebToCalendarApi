require_relative "../../../../test/test_helper"
require "webmock/minitest"

class WebToCalendarApi::VillaKuriosum::ScraperTest < Minitest::Test
  def test_run
    Dir.children("#{__dir__}/fixtures").each do |filename|
      body = File.read("#{__dir__}/fixtures/#{filename}")

      if filename == "monatsprogramm.html" # The main Calendar
        stub_request(:get, "http://villakuriosum.net/index.php/#{filename.gsub(".html", "")}").to_return(:body => body)
      else ## The info pages
        stub_request(:get, "http://villakuriosum.net/index.php/monatsprogramm/15-events/#{filename.gsub(".html", "")}").to_return(:body => body)
      end
    end

    result = JSON.pretty_generate WebToCalendarApi::VillaKuriosum::Scraper.run

    # puts "Warning: writing fixture!"
    # File.open("#{__dir__}/fixtures/calendar.json", "w") do |f|
    #   f.write result
    # end

    assert_equal(File.read("#{__dir__}/fixtures/calendar.json"), result)
  end
end
