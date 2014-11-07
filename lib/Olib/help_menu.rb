module Olib

  class HelpMenu < String
    def initialize s
      super s.to_s    # this line added
      @s      = Script.self.name.ljust(20)
      @s.concat "\n"
      @simple = s.index(?+)
    end

    def add_cmd(cmd, help_line)
      concat cmd.ljust(40)
      concat help_line.ljust(100)
      concat "\n"
    end
  end

end