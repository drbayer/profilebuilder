
class Profile::Shell < JSONable
    include ProfileBuilder

    CONFIG = Profile::Shell.get_config('shell')
    BASEPATH = CONFIG.key?("basepath") ? File.expand_path(CONFIG["basepath"]) : File.expand_path("~/")

    attr_reader :dotfiles
    attr_reader :current_shell

    def record
        @current_shell = self.get_current
        @dotfiles = self.get_dotfiles
    end

    def save_dotfiles(tarfile, overwrite = false)
        require 'fileutils'
        raise "No dot files found to save" if !@dotfiles or @dotfiles.length == 0

        savefile = File.expand_path(tarfile)
        bakfile = "#{savefile}.bak"

        if File.exists?(savefile)
            if overwrite
                File.delete(bakfile) if File.exists?(bakfile)
            else
                raise "Dot file archive #{savefile} already exists."
            end
            FileUtils.cp(savefile, bakfile)
        end

        begin
            self.tar_gz(BASEPATH, savefile, *@dotfiles)
        rescue
            if File.exists?(bakfile)
                FileUtils.mv(bakfile, savefile, force: true)
            else
                File.delete(savefile)
            end
        end
    end

    protected

      def tar_gz(path, tarfile, *src)
          require 'rubygems/package'
          require 'find'
          require 'pathname'

          basepath = Pathname.new(path)
          raise ArgumentError, "Path #{path} should be an absolute path" unless basepath.absolute?
          raise ArgumentError, "Path #{path} should be a directory" unless File.directory?(path)
          raise ArgumentError, "No files/directories found to tar" if !src or src.length == 0
          raise Argumenterror, "Destination file #{tarfile} already exists" if File.exist?(tarfile)

          src.each {|p| p.sub!(/^/, "#{path}/")}
          File.open(tarfile, "wb") do |tf|
              Zlib::GzipWriter.wrap(tf) do |gz|
                  Gem::Package::TarWriter.new(gz) do |tar|
                      Find.find(*src) do |f|
                          relpath = f.sub("#{path}/", "")
                          mode = File.stat(f).mode
                          size = File.stat(f).size
                          if File.directory?(f)
                              tar.mkdir(relpath, f)
                          else
                              tar.add_file_simple(relpath, mode, size) do |tio|
                                  File.open(f, "rb") do |rio|
                                      while buffer = rio.read(BLOCKSIZE)
                                          tio.write(buffer)
                                      end
                                  end
                              end
                          end
                      end
                  end
              end
          end
      end

    def get_current
        ENV['SHELL']
    end

    def get_dotfiles
        puts CONFIG
        files = Dir.glob("\.[a-zA-Z0-9-_]*", base: BASEPATH)
        keep_files = files.dup
        exc = []
        inc = []

        if CONFIG.include?('exclude')
            exc = CONFIG['exclude'].split(',').map {|x| x.strip}
        end

        if CONFIG.include?('include')
            inc = CONFIG['include'].split(',').map {|x| x.strip}
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
