require "rubygems"
require "nokogiri"
require "open-uri"
require "json"
require "digest"

module WebToCalendarApi
  module BWareLandenkino
    module Scraper
      VENUE = "b-ware! ladenkino"
      ROOT_URL = "http://ladenkino.de/"
      TIME_ZONE = "Berlin"

      def self.run
        parse_calendar
      end

      def self.parse_info(url)
        puts "Parsing Info: #{url}"

        # puts "Warning: writing fixture!"
        # File.open("#{__dir__}/test/fixtures/#{File.basename(url)}.html", "w") do |f|
        #   f.write open(url).read
        # end

        element = Nokogiri::HTML(open(url))
        info = element.css(".entry-content p").map(&:text).map(&:strip).select { |text| !text.empty? }

        info
      rescue OpenURI::HTTPError => e
        puts "ERROR on parsing URL: #{url}, #{e.message}"

        return ["ERROR parsing this Information"]
      end

      def self.parse_calendar
        puts "Parsing Calendar :: #{VENUE}"

        # puts "Warning: writing fixture!"
        # File.open("#{__dir__}/test/fixtures/index.html", "w") do |f|
        #   f.write HTTParty.get(ROOT_URL)
        # end

        ## Collection
        page = Nokogiri::HTML(open(ROOT_URL))

        elements = page.css("table#tablepress-13 tbody tr")

        results =
          elements.map do |element|
            parse_calendar_element(element)
          end

        results

        result = {
          "title" => VENUE,
          "calendar_url" => "#{ROOT_URL}/index.php/monatsprogramm",
          "calendar_elements" => results
        }

        result
      end

      def self.parse_calendar_element(calendar_element)
        title = calendar_element.css("td.column-3").text
        puts "Parsing: #{title}"
        url = calendar_element.css("td.column-4 a").attribute("href")
        date = calendar_element.css("td.column-1").text.strip
        date = date.split(" ")[0]
        date = date + "." + Time.now.year.to_s
        date = Date.parse(date)

        hour = calendar_element.css("td.column-2").text.strip

        date_time = Time.parse("#{date.to_s} #{hour} #{TIME_ZONE}")

        checksum = Digest::SHA2.hexdigest("#{VENUE}#{title}#{url}#{date_time}")

        result = {
          "checksum" => checksum,
          "title" => title,
          "url" => url,
          "date_time" => date_time,
          "info" => parse_info(url),
          "pics" => [], # parse_pics(url),
          "tags" => ["cinema"]
        }

        result
      end
    end
  end
end

