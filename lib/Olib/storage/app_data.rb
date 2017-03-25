require 'fileutils'

module Olib
  class App
    APP_DIR = Dir.home + "/." + self.name.downcase
    ##
    ## setup app dir
    ##
    FileUtils.mkdir_p APP_DIR

    def self.app_file(path)
      APP_DIR + "/" + path
    end

    def self.open(file)
      File.open(app_file(file), 'a', &block)
    end

    def self.write(file, data)
      open(file) do |f|
        JSON.stringify(data)
      end
    end

    def self.read(file, &block)
      open(file) do |file|
        yield
      end
    end
  end
end