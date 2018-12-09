
class Shell < JSONable
    include ProfileBuilder

    def initialize
        @config = Shell.get_config
    end

    def record
        @current_shell = self.current
        @dotfiles = self.dotfiles
    end

    def current
        ENV['SHELL']
    end

    def dotfiles
        puts @config
        files = Dir.glob("\.[a-zA-Z0-9-_]*", base: File.expand_path('~/'))
        keep_files = files.dup
        exc = []
        inc = []

        if @config.include?('exclude')
            exc = @config['exclude'].split(',').map {|x| x.strip}
        end

        if @config.include?('include')
            inc = @config['include'].split(',').map {|x| x.strip}
        end

        exc.map do |x| 
            x.gsub!('.', '\.')
            x.gsub!('*', '.*')
            x = "^#{x}$"
            keep_files.delete_if {|f| /#{x}/ =~ f}
        end

        inc.map do |x| 
            x.gsub!('.', '\.')
            x.gsub!('*', '.*')
            x = "^#{x}$"
            files.map {|f| keep_files << f if /#{x}/ =~ f}
        end
        
        keep_files
    end

end
