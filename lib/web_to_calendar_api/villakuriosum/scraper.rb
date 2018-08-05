require "rubygems"
require "nokogiri"
require "open-uri"
require "json"
require "digest"

root_url = "http://villakuriosum.net"
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
  page = Nokogiri::HTML(open("#{root_url}/index.php/monatsprogramm"))

  elements = page.css(".events_container tr:nth-child(n+2)")#.select { |element| !element.attribute("colspan") == "3" }

  results =
    elements.map do |element|
      parse_calendar_element(element, root_url, time_zone)
    end

  results
end

def parse_calendar_element(calendar_element, root_url, time_zone)
  title = calendar_element.css(":nth-child(1) a:nth-child(1)").text
  puts "Parsing: #{title}"
  path = calendar_element.css(":nth-child(1) a:nth-child(1)").attribute("href")
  date = calendar_element.css(":nth-child(2)").text.strip
  date = Date.parse(date)

  hour = calendar_element.css(":nth-child(3)").text.strip

  date_time = Time.parse("#{date.to_s} #{hour} #{time_zone}")

  check_sum = Digest::SHA2.hexdigest("#{title}#{path}#{date_time}")

  result = {
    :check_sum => check_sum,
    :title => title,
    :url => "#{root_url}#{path}",
    :date_time => date_time,
    :info => parse_info(path, root_url),
    :pics => parse_pics(path, root_url),
  }

  result
end

# puts parse_calendar(root_url)
# exit 0

result = {
  "title" => "Villa Kuriosum",
  "calendar_url" => "http://villakuriosum.net/index.php/monatsprogramm",
  "calendar_elements" => parse_calendar(root_url, time_zone)
}

puts JSON.pretty_generate result

