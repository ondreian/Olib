require 'net/http'
require 'json'

module Olib

  def Olib.update_notifier
    begin
        response  = JSON.parse Net::HTTP.get URI('https://rubygems.org/api/v1/gems/Olib.json')
        # check version
        if Gem.loaded_specs["Olib"].version < Gem::Version.new(response['version'])
          puts "<pushBold/>You need to update the Olib gem with a `gem install Olib`<popBold/>"
        end
        
      rescue
        echo $!
        puts $!.backtrace[0..1]
      end
  end

  def Olib.methodize(str)
    str.downcase.strip.gsub(/-|\s+|'|"/, "_")
  end

  # load core first
  Dir[File.dirname(__FILE__) + '/Olib/core/**/*.rb'].each {|file|
    require file 
  }

  # load things that depend on core extensions
  Dir[File.dirname(__FILE__) + '/Olib/**/*.rb'].each {|file|
    require file 
  }

  # invoke update notifier immediately
  Olib.update_notifier

  def Olib.do(action, re)
    dothistimeout action, 5, re
  end

  def Olib.run(script, *args)
    start_script script, args
    wait_while { running? script }
  end

  def Olib.install(g, v=nil)
    if !which("gem") then
      echo "Olib could not detect the `gem` executable in your $PATH"
      echo "when you installed Ruby did you forget to click the `modify $PATH` box?"
      raise Exception
    end

    begin
      unless v.nil?
        # make it a true instance of Gem::Version so we can compare
        raise UpdateGemError if Gem.loaded_specs[g].version <  Gem::Version.new(v)
        gem g, v
      end

      Olib.reload g

    ##
    ## rescue missing gem and reload after install
    ##
    rescue LoadError
      echo "installing #{g}..."
      version = "--version '#{v}'" unless v.nil?
      worked = system("gem install #{g} #{version} --no-ri --no-rdoc")
      unless worked then raise "Could not install #{g} gem" end
      Olib.reload g
      echo "... installed #{g}!"

    ##
    ## rescue from too old of a gem version for a Ruby environment
    ##
    rescue UpdateGemError
      echo "updating #{g}@#{Gem.loaded_specs[g].version} => #{v}..."
      version = "--version '#{v}'" unless v.nil?
      worked = system("gem install #{g} #{version} --no-ri --no-rdoc")
      unless worked then raise "Could not install #{g} gem" end
      Olib.reload g
      echo "... updated #{g} to #{v}!"
    end
  end

  Vars.Olib ||= Hash.new


end