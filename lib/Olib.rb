module Olib
  def Olib.do(action, re)
    dothistimeout action, 5, re
  end

  require 'Olib/group'
  require 'Olib/creature'
  require 'Olib/creatures'
  require 'Olib/extender'
  require 'Olib/transport'
  require 'Olib/item'
  require 'Olib/dictionary'
  require 'Olib/container'
  require 'Olib/help_menu'
  
end