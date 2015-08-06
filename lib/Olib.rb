require 'net/http'
require 'json'

module Olib

  def Olib.update_notifier
    begin
        request  = Net::HTTP::Get.new('/api/v1/gems/Olib.json', initheader = {'Content-Type' =>'application/json'})
        response = Net::HTTP.new('rubygems.org').start {|http| http.request(request) }
        if response.body =~ /error/
          # silence is golden
          exit
        else
          # check version
          if Gem.loaded_specs["Olib"].version < Gem::Version.new(JSON.parse(response.body)['version'])
            respond "You need to update the Olib gem with a `gem install Olib`"
          end
        end
      rescue
        echo $!
        puts $!.backtrace[0..1]
      end
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

  Vars.Olib ||= Hash.new


  
end