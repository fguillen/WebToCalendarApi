
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "web_to_calendar_api/version"

Gem::Specification.new do |spec|
  spec.name          = "web_to_calendar_api"
  spec.version       = WebToCalendarApi::VERSION
  spec.authors       = ["Fernando Guillen"]
  spec.email         = ["fguillen.mail@gmail.com"]

  spec.summary       = "Multi Webs to JSON API"
  spec.description   = "Multi Webs to JSON API"
  spec.homepage      = "https://github.com/fguillen/WebToCalendarApi"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "0.16.2"
  spec.add_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock"
end
