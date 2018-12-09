
class HomeBrew < JSONable
    include ProfileBuilder

    def record
        @installed = self.installed?
        if @installed
            @casks = self.casks
            @formulae = self.formulae
        end
    end

    def installed?
        path = HomeBrew.which('brew')
        installed = path.empty? ? false : true
        installed
    end

    def casks
        %x(brew cask list).split("\n")
    end

    def formulae
        %x(brew list).split("\n")
    end

end

