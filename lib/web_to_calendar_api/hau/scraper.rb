require "rubygems"
require "nokogiri"
require "open-uri"
require "json"
require "digest"

root_url = "https://www.hebbel-am-ufer.de"
time_zone = "Berlin"



def parse_info(url, root_url)
  element = Nokogiri::HTML(open("#{root_url}#{url}"))
  info = element.css("#description").children.map(&:text).map { |text| text.gsub(Nokogiri::HTML("&nbsp;"), "") }.map(&:strip).select { |text| !text.empty? }

  info
end

# puts JSON.pretty_generate parse_info("/index.php/monatsprogramm/15-events/191-nostructure", root_url)
# exit 0

def parse_pics(url, root_url)
  element = Nokogiri::HTML(open("#{root_url}#{url}"))
  pics = element.css("#description img").map { |element| element.attribute("src") }.map(&:text)

  # Transform

  pics =
    pics.map do |pic|
      if !pic.match(/^http/)
        "#{root_url}#{pic}"
      else
        pic
      end
    end

  pics
end

# puts JSON.pretty_generate parse_pics("/index.php/monatsprogramm/15-events/191-nostructure", root_url)
# exit 0


def parse_calendar(root_url, time_zone)
  puts "Parsing Calendar"

  ## Collection
  page = Nokogiri::HTML(open("#{root_url}/programm/spielplan/"))

  elements = page.css("div.performanceInfo")

  results =
    elements.map do |element|
      parse_calendar_element(element, root_url, time_zone)
    end

  results
end

# parse_calendar(root_url, time_zone)
# exit 0

def parse_calendar_element(calendar_element, root_url, time_zone)
  title = calendar_element.css("h2.stdEl").text
  puts "Parsing: #{title}"

  url = calendar_element.css("h2.stdEl a").attribute("href").text
  hour = calendar_element.css(".performanceDate_stage").text.split(" / ").first
  venue = calendar_element.css(".performanceDate_stage").text.split(" / ").last
  date = calendar_element.ancestors(".pageContent_row").first.previous_element.attribute("name").text

  date = date.gsub("_", ".")
  date = Date.parse date

  date_time = Time.parse("#{date.to_s} #{hour} #{time_zone}")

  check_sum = Digest::SHA2.hexdigest("#{title}#{url}#{date_time}")

  result = {
    :check_sum => check_sum,
    :title => title,
    :url => url,
    :date_time => date_time,
    :info => ["NOT_IMPLEMENTED"], #parse_info(url, root_url),
    :pics => ["NOT_IMPLEMENTED"] #parse_pics(url, root_url),
  }

  result
end

# puts parse_calendar(root_url)
# exit 0

result = {
  "title" => "Villa Kuriosum",
  "calendar_url" => "https://www.hebbel-am-ufer.de/programm/spielplan",
  "calendar_elements" => parse_calendar(root_url, time_zone)
}

puts JSON.pretty_generate result

