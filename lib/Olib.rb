require 'net/http'
require 'json'
require "ostruct"

class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end

class MatchData
  def to_struct
    OpenStruct.new to_hash
  end

  def to_hash
    Hash[self.names.zip(self.captures.map(&:strip).map do |capture|  
      if capture.is_i? then capture.to_i else capture end
    end)]
  end
end

class Hash
  def to_struct
    OpenStruct.new self
  end
end

class Regexp
  def or(re)
    Regexp.new self.to_s + "|" + re.to_s
  end
  # define union operator for regex instance
  def |(re)
    self.or(re)
  end
end

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
    str.to_s.downcase.strip.gsub(/-|\s+|'|"/, "_").to_sym
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
  # Olib.update_notifier

  def Olib.do(action, re)
    dothistimeout action, 5, re
  end

  def Olib.run(script, *args)
    start_script script, args
    wait_while { running? script }
  end

  Vars.Olib ||= Hash.new


end