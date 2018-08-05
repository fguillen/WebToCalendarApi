require "rubygems"
require "nokogiri"
require "open-uri"
require "json"
require "digest"

module WebToCalendarApi
  module VillaKuriosum
    module Scraper
      VENUE = "Villa Kuriosum"
      ROOT_URL = "http://villakuriosum.net"
      TIME_ZONE = "Berlin"

      def self.run
        parse_calendar
      end


      def self.parse_info(url)
        element = Nokogiri::HTML(open("#{ROOT_URL}#{url}"))
        info = element.css("#description").children.map(&:text).map { |text| text.gsub(Nokogiri::HTML("&nbsp;"), "") }.map(&:strip).select { |text| !text.empty? }

        info
      end

      # puts JSON.pretty_generate parse_info("/index.php/monatsprogramm/15-events/191-nostructure")
      # exit 0

      def self.parse_pics(url)
        element = Nokogiri::HTML(open("#{ROOT_URL}#{url}"))
        pics = element.css("#description img").map { |element| element.attribute("src") }.map(&:text)

        # Transform

        pics =
          pics.map do |pic|
            if !pic.match(/^http/)
              "#{ROOT_URL}#{pic}"
            else
              pic
            end
          end

        pics
      end

      # puts JSON.pretty_generate parse_pics("/index.php/monatsprogramm/15-events/191-nostructure")
      # exit 0


      def self.parse_calendar
        puts "Parsing Calendar"

        ## Collection
        page = Nokogiri::HTML(open("#{ROOT_URL}/index.php/monatsprogramm"))

        elements = page.css(".events_container tr:nth-child(n+2)")#.select { |element| !element.attribute("colspan") == "3" }

        results =
          elements.map do |element|
            parse_calendar_element(element)
          end

        results

        # puts parse_calendar(ROOT_URL)
        # exit 0

        result = {
          "title" => "Villa Kuriosum",
          "calendar_url" => "http://villakuriosum.net/index.php/monatsprogramm",
          "calendar_elements" => results
        }

        result
      end

      def self.parse_calendar_element(calendar_element)
        title = calendar_element.css(":nth-child(1) a:nth-child(1)").text
        puts "Parsing: #{title}"
        path = calendar_element.css(":nth-child(1) a:nth-child(1)").attribute("href")
        date = calendar_element.css(":nth-child(2)").text.strip
        date = Date.parse(date)

        hour = calendar_element.css(":nth-child(3)").text.strip

        date_time = Time.parse("#{date.to_s} #{hour} #{TIME_ZONE}")

        checksum = Digest::SHA2.hexdigest("#{VENUE}#{title}#{path}#{date_time}")

        result = {
          "checksum" => checksum,
          "title" => title,
          "url" => "#{ROOT_URL}#{path}",
          "date_time" => date_time,
          "info" => parse_info(path),
          "pics" => parse_pics(path),
        }

        result
      end
    end
  end
end

