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
        #   f.write HTTParty.get("#{ROOT_URL}/programm/spielplan-tickets/")
        # end

        ## Collection
        page = Nokogiri::HTML(open("#{ROOT_URL}/programm/spielplan-tickets/"))

        month = page.css(".month-box h3").first.content.strip.split(/\W/)[0]
        year = page.css(".month-box h3").first.content.strip.split(/\W/)[1]

        days = page.css("#prodList .day.module")

        results = []

        days.each do |day|
          results.append(parse_day(day, year, month))
        end

        # elements = page.css("styled-cell content")

        # results =
        #   elements.map do |element|
        #     parse_calendar_element(element)
        #   end

        result = {
          "title" => VENUE,
          "calendar_url" => "#{ROOT_URL}/programm/spielplan/",
          "calendar_elements" => results
        }

        result
      end

      def self.parse_day(day_element, year, month)
        day_number = day_element.css(".big").first.content.strip.split(" ")[1]
        # puts "day_number: #{day_number}"

        date = Date.parse("#{year}-#{month}-#{day_number}")
        puts "date: #{date}"

        items = day_element.css(".item")
        results =
          items.map do |item|
            parse_item(item, date)
          end.compact

        results
      end

      def self.parse_item(item_element, date)
        # puts "item_element: #{item_element}"
        time = item_element.css(".floats--extended strong").first&.content&.strip
        # puts "time: #{time}"
        if(time.nil?)
          return nil
        end

        venue = item_element.css(".event-venue--extended").first.content.strip.split(" ")[0]
        # puts "venue: #{venue}"

        button = item_element.css(".show-btn").first
        # puts "button: #{button["href"]}"

        url = button["href"]
        hour = time
        venue = venue
        date = date
        title = item_element.css("h3").first

        date_time = Time.parse("#{date.to_s} #{time} #{TIME_ZONE}")

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

      # def self.parse_calendar_element(calendar_element)
      #   title = calendar_element.css("h3, h4").join(" - ")
      #   puts "Parsing: #{title}"

      #   url = calendar_element.css("h2.stdEl a").attribute("href").text
      #   hour = calendar_element.css(".performanceDate_stage").text.split(" / ").first
      #   venue = calendar_element.css(".performanceDate_stage").text.split(" / ").last
      #   date = calendar_element.ancestors(".pageContent_row").first.previous_element.attribute("name").text

      #   date = date.gsub("_", ".")
      #   date = Date.parse date

      #   date_time = Time.parse("#{date.to_s} #{hour} #{TIME_ZONE}")

      #   checksum = Digest::SHA2.hexdigest("#{VENUE}#{title}#{url}#{date_time}")

      #   result = {
      #     "checksum" => checksum,
      #     "title" => title,
      #     "url" => url,
      #     "date_time" => date_time,
      #     "info" => ["NOT_IMPLEMENTED"], #parse_info(url),
      #     "pics" => [], #parse_pics(url),
      #     "tags" => ["theater", "performance", "dance"]
      #   }

      #   result
      # end

    end
  end
end
