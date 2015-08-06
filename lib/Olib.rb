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

  # invoke update notifier immediately
  Olib.update_notifier

  def Olib.do(action, re)
    dothistimeout action, 5, re
  end

  Vars.Olib ||= Hash.new

  require 'Olib/group'
  require 'Olib/creature'
  require 'Olib/creatures'
  require 'Olib/extender'
  require 'Olib/transport'
  require 'Olib/item'
  require 'Olib/dictionary'
  require 'Olib/errors'
  require 'Olib/container'
  require "Olib/inventory"
  require "Olib/shops"
  require 'Olib/help_menu'
  require "Olib/utils"
  
end