require 'fileutils'

module Olib
  class App
    FOLDER  = ".olib"
    APP_DIR = File.join Dir.home, FOLDER
    ##
    ## setup app dir
    ##
    FileUtils.mkdir_p APP_DIR

    def self.app_file(path)
      File.join APP_DIR, path
    end

    def self.open(file)
      File.open(app_file(file), 'a', &block)
    end

    def self.write_json(file, data)
      open(file) do |f|
        JSON.dump(data)
      end
    end

    def self.read(file, &block)
      open(file) do |file|
        yield
      end
    end
  end
end