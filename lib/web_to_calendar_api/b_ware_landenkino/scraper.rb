require "rubygems"
require "nokogiri"
require "open-uri"
require "json"
require "digest"

module WebToCalendarApi
  module BWareLandenkino
    module Scraper
      VENUE = "b-ware! ladenkino"
      ROOT_URL = "https://www.kinoheld.de/ajax/getShowsForCinemas?cinemaIds[]=108&cinemaIds[]=1657&lang=en"
      TIME_ZONE = "Berlin"

      def self.run
        parse_calendar
      end

      def self.get_program
        JSON.parse(HTTParty.get(ROOT_URL).body)
      end

      def self.parse_calendar
        puts "Parsing Calendar :: #{VENUE}"

        program = get_program

        puts "Warning: writing fixture!"
        File.open("#{__dir__}/test/fixtures/program.json", "w") do |f|
          f.write JSON.pretty_generate program
        end

        ## Movies
        elements = program["shows"]

        results =
          elements.map do |element|
            parse_calendar_element(element, program)
          end

        results

        result = {
          "title" => VENUE,
          "calendar_url" => "#{ROOT_URL}",
          "calendar_elements" => results
        }

        result
      end

      def self.parse_calendar_element(calendar_element, program)
        movieId = calendar_element["movieId"]

        puts "Parsing: #{movieId}/#{calendar_element["beginning"]["isoFull"]}"

        movie_details = program["movies"][movieId]

        if movie_details.nil?
          puts "Not found details for movie: #{movieId}"
          movie_details = {}
        end

        title = calendar_element["name"]
        url = "https://ladenkino.de/"
        date_time = Time.parse(calendar_element["beginning"]["isoFull"])
        checksum = Digest::SHA2.hexdigest("#{VENUE}#{movieId}#{date_time}")

        if !movie_details["description"].nil?
          info = movie_details["description"].split(". ")
        end

        pics = []

        if !movie_details["largePosterImage"].nil?
          pics << movie_details["largePosterImage"].first["url"]
        end

        if !movie_details["largeSceneImages"].nil?
          pics << movie_details["largeSceneImages"].map { |e| e.first["url"] }
        end

        pics = pics.flatten.compact

        result = {
          "checksum" => checksum,
          "title" => title,
          "url" => url,
          "date_time" => date_time,
          "info" => info,
          "pics" => pics,
          "tags" => ["cinema"]
        }

        result
      end
    end
  end
end

