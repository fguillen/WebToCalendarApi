require "rubygems"
require "nokogiri"
require "open-uri"
require "json"
require "digest"

module WebToCalendarApi
  module HAU
    module Scraper
      VENUE = "HAU"
      ROOT_URL = "https://www.hebbel-am-ufer.de"
      TIME_ZONE = "Berlin"

      def self.run
        parse_calendar
      end

      def self.parse_calendar
        puts "Parsing Calendar :: #{VENUE}"

        # puts "Warning: writing fixture!"
        # File.open("#{__dir__}/test/fixtures/spielplan.html", "w") do |f|
        #   f.write HTTParty.get("#{ROOT_URL}/programm/spielplan/")
        # end

        ## Collection
        page = Nokogiri::HTML(open("#{ROOT_URL}/programm/spielplan/"))

        elements = page.css("div.performanceInfo")

        results =
          elements.map do |element|
            parse_calendar_element(element)
          end

        results

        result = {
          "title" => VENUE,
          "calendar_url" => "#{ROOT_URL}/programm/spielplan/",
          "calendar_elements" => results
        }

        result
      end

      def self.parse_calendar_element(calendar_element)
        title = calendar_element.css("h2.stdEl").text
        puts "Parsing: #{title}"

        url = calendar_element.css("h2.stdEl a").attribute("href").text
        hour = calendar_element.css(".performanceDate_stage").text.split(" / ").first
        venue = calendar_element.css(".performanceDate_stage").text.split(" / ").last
        date = calendar_element.ancestors(".pageContent_row").first.previous_element.attribute("name").text

        date = date.gsub("_", ".")
        date = Date.parse date

        date_time = Time.parse("#{date.to_s} #{hour} #{TIME_ZONE}")

        checksum = Digest::SHA2.hexdigest("#{VENUE}#{title}#{url}#{date_time}")

        result = {
          "checksum" => checksum,
          "title" => title,
          "url" => url,
          "date_time" => date_time,
          "info" => ["NOT_IMPLEMENTED"], #parse_info(url),
          "pics" => [], #parse_pics(url),
          "tags" => ["theater", "performance", "dance"]
        }

        result
      end

    end
  end
end

