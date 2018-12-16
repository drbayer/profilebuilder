
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "profilebuilder/version"
require 'date'

Gem::Specification.new() do |s|
    s.name        	= 'profilebuilder'
    s.version       = ProfileBuilder::VERSION
    s.date        	= "#{Date::today}"
    s.summary     	= "Saves or restores bash profile components"
    s.description   = ["Creates a portable file with recorded aspects of your",
                       "bash profile. Can restore the recorded profile onto a new",
                       "user profile as needed. Includes Homebrew for Mac users."].join(" ")
    s.authors       = ["David Bayer"]
    s.email         = 'drbayer@eternalstench.com'
    s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
    s.require_paths = ["lib"]
    s.homepage      = 'https://github.com/drbayer/profilebuilder'
    s.license       = 'MIT'

    s.add_runtime_dependency 'date', '~>1.0'
    s.add_runtime_dependency 'fileutils', '~>1.0'
    s.add_runtime_dependency 'json', '~>2.1'
    s.add_runtime_dependency 'parseconfig', '~>1.0'

    s.add_development_dependency 'rspec', '~>3.8'
end

