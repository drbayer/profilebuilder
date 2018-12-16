
class Profile::HomeBrew < JSONable
    include ProfileBuilder

    attr_reader :casks
    attr_reader :formulae

    def record
        @installed = self.installed?
        if @installed
            @casks = self.get_casks
            @formulae = self.get_formulae
        end
    end

    def installed?
        path = Profile::HomeBrew.which('brew')
        installed = path.empty? ? false : true
        installed
    end

    protected

    def get_casks
        %x(brew cask list).split("\n")
    end

    def get_formulae
        %x(brew list).split("\n")
    end

end

