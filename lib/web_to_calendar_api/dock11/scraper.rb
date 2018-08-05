require "rubygems"
require "nokogiri"
require "httparty"
require "json"
require "digest"

module WebToCalendarApi
  module Dock11
    module Scraper
      VENUE = "Dock11"
      ROOT_URL = "http://www.dock11-berlin.de/"
      TIME_ZONE = "Berlin"

      def self.run
        parse_calendar
      end

      def self.parse_info(url)
        # File.open("#{__dir__}/test/fixtures/#{File.basename(url)}", "w") do |f|
        #   f.write open("#{ROOT_URL}#{url}").read
        # end

        element = Nokogiri::HTML(HTTParty.get("#{ROOT_URL}#{url}"))
        info = element.css("#content1 p").map(&:text).map { |text| text.gsub(Nokogiri::HTML("&nbsp;"), "") }.map(&:strip).select { |text| !text.empty? }

        info
      end

      # puts JSON.pretty_generate parse_info("index.php/cat/1_0/id/p709_darwintodarwin.html")
      # exit 0

      def self.parse_pics(url)
        element = Nokogiri::HTML(HTTParty.get("#{ROOT_URL}#{url}"))
        pics = element.css("#content1 p img").map { |element| element.attribute("src") }.map(&:text)

        # Transform

        pics =
          pics.map do |pic|
            if !pic.match(/^http/)
              "#{ROOT_URL}/#{pic}"
            else
              pic
            end
          end

        pics
      end


      def self.parse_calendar
        # File.open("#{__dir__}/test/fixtures/c1_Veranstaltungen.html", "w") do |f|
        #   f.write HTTParty.get("#{ROOT_URL}/index.php/cat/c1_Veranstaltungen.html")
        # end

        puts "Parsing Calendar"

        page = Nokogiri::HTML(HTTParty.get("#{ROOT_URL}index.php/cat/c1_Veranstaltungen.html"))

        titles = page.css("#content1 a strong").map(&:text).map(&:strip).select { |text| !text.empty? and text != "ticket@dock11-berlin.de" } # titles
        links = page.css("#content1 a strong").map { |element| element.parent.attribute("href").text }.map(&:strip).select { |link| link != "mailto:ticket@dock11-berlin.de" } # links to info
        dates = page.css("#content1 td:nth-child(1) strong").map(&:text).map(&:strip).select { |text| text.match(/^\d\d/)} # dates
        hours = page.css("td:nth-child(2) strong").map(&:text).map(&:strip).select { |text| text.match("Uhr")} # hours

        ## Transformation

        ### Dates

        date_sequences = []

        dates.each do |date|
          # if "bis"
          if date.match("bis")
            date_end = date.split(" bis ").last
            date_ini = date.split(" bis ").first
            date_ini = date_ini + date_end[date_ini.length, date_end.length]
          else
            date_end = date
            date_ini = date
          end

          date_ini = Date.parse date_ini
          date_end = Date.parse date_end

          actual_date = date_ini
          date_sequence = []
          while(actual_date <= date_end) do
            date_sequence << actual_date
            actual_date += 1
          end

          date_sequences << date_sequence
        end

        ### Hours
        hours = hours.map { |hour| hour.gsub(" Uhr", "") }

        ## Aggregations

        results = []

        titles.each_with_index do |title, index|
          puts "Parsing: #{title}"

          url = links[index]
          hour = hours[index]

          date_sequences[index].each do |date|
            date_time = Time.parse("#{date.to_s} #{hour} #{TIME_ZONE}")
            check_sum = Digest::SHA2.hexdigest("#{VENUE}#{title}#{url}#{date_time}")

            results << {
              :check_sum => check_sum,
              :title => title,
              :url => "#{ROOT_URL}/#{url}",
              :date_time => date_time,
              :info => parse_info(url),
              :pics => parse_pics(url),
            }
          end
        end

        results

        result = {
          "title" => "Dock11",
          "calendar_url" => "http://www.dock11-berlin.de/index.php/cat/c1_Veranstaltungen.html",
          "calendar_elements" => results
        }

        result
      end
    end
  end
end

