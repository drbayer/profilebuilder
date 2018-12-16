#!/usr/bin/env ruby

require './lib/profilebuilder'

describe ProfileBuilder do

    it "returns a version string" do
        expect(Gem::Version.correct?(ProfileBuilder.version)).to be(true)
    end


    it "finds the executable" do
        executable = File.basename(ENV['SHELL'])
        expect(Profile.which(executable)).to eq(ENV['SHELL'])
    end

    it "should return the Shell config" do
        stub_const("CONFIG", "fixtures/files/config")
        config = Profile.get_config('shell')
        expect(config).not_to be_empty
        expect(config).to be_a_kind_of(Hash)
        expect(config).to have_key("include")
        expect(config).to have_key("exclude")
    end

end

describe Profile do

    context "when homebrew is installed" do

        p = Profile.new
        p.homebrew.record

        it "should have casks" do
            expect(p.homebrew.casks).to be_a_kind_of(Array)
        end

        it "should have formulae" do
            expect(p.homebrew.formulae).to be_a_kind_of(Array)
            expect(p.homebrew.formulae.length).to be > 0
        end

        it "should be installed" do
            expect(p.homebrew.installed?).to be(true)
        end

    end

end

