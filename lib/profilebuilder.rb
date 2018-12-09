module ProfileBuilder
    require "profilebuilder/version"

    CONFIG = File.expand_path('~/.profilebuilder/config')

    def self.included(base)
        base.extend(ClassMethods)
    end

    module ClassMethods
        def which(binary)
            ret = ''
            possibles = ENV["PATH"].split(File::PATH_SEPARATOR)
            possibles.map {|p| File.join(p, binary)}.find {|p| ret = p if File.executable?(p)}
            ret
        end

        def get_config
            require 'parseconfig'

            cfg = self.class.name.downcase
            fullconfig = ParseConfig.new(CONFIG)
            config = {}
            config = fullconfig[cfg] if fullconfig.get_params.include?(cfg)
            config
        end
    end

    def ProfileBuilder.version
        puts ProfileBuilder::VERSION
    end

end

class JSONable
    require 'json'

    def to_json
        hash = {}
        self.instance_variables.each do |var|
            hash[var] = self.instance_variable_get(var)
        end
        hash.to_json
    end

    def from_json!(string)
        JSON.load(string).each do |var, val|
            self.instance_variable_set(var, val)
        end
    end

end

class Profile
    require "profilebuilder/shell"
    require "profilebuilder/homebrew"

    include ProfileBuilder

    def initialize
        @shell = Shell.new
        @homebrew = HomeBrew.new
    end

    def shell
        @shell
    end

    def homebrew
        @homebrew
    end
end

