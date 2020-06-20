require "ostruct"

module Olib
  # load ext first
  Dir[File.dirname(__FILE__) + '/Olib/ext/**/*.rb'].each do |file| require(file) end
  # load core next
  Dir[File.dirname(__FILE__) + '/Olib/core/**/*.rb'].each do |file| require(file) end
  # load things that depend on core extensions
  Dir[File.dirname(__FILE__) + '/Olib/**/*.rb'].each do |file| require(file) end
end
