module Olib
  class HelpMenu
    attr_accessor :script, :cmds, :last_added, :flags, :title, :padding, :cols, :max_column_width

    def initialize
      @script = $lich_char+Olib.script.to_s
      @cmds                = {}
      @flags               = {}
      @padding             = 5
      @max_column_width    = Vars.max_column_width.to_i || 50
      @title  = "#{@script} help menu".upcase
      self
    end

    def flag(flag, info)
      if @last_added
        @cmds[@last_added][:flags][flag] = info
      else
        @flags[flag] = info
      end
        
      self
    end

    def pad
      [''] * @padding * ' '
    end

    def cmd(cmd, info)
      @last_added         = cmd
      @cmds[cmd]          = {}
      @cmds[cmd][:info]   = info
      @cmds[cmd][:flags]  = {}
      self
    end

    def width
      return @cols if @cols
      
      @cols        = {}
      @cols[:one]  = @script.length+padding

      # global flags and commands
      @cols[:two]  = @flags
        .keys
        .concat(@cmds.keys)
        .map(&:strip)
        .sort_by(&:length).last.length+padding

      # flags
      @cols[:three] = @cmds
        .keys
        .map { |cmd| @cmds[cmd][:flags].keys }
        .flatten
        .map(&:strip)
        .sort_by(&:length).last.length+padding

      # help text
      @cols[:four] = @max_column_width+padding

      @cols[:total] = @cols.values.reduce(&:+)

      @cols
    end

    def center(str)
      "%#{width.values.reduce(&:+)/3-str.length}s\n" % str
    end

    # offset the entire array of eles by n number of blank strings
    def offset(n, *eles)
      row *(eles.unshift *[''] * n)
    end

    def row(*columns)
      "%#{width[:one]}s %#{width[:two]}s#{pad}%-#{width[:three]}s#{pad}%-#{width[:four]}s\n" % columns.map(&:strip)
      #row2 *columns
    end

    def bar
      "|\n".rjust(width[:total]+10,"-")
    end

    def n
      "\n"
    end

    def chunker(content)
      rows = ['']

      content.split.each { |chunk|
        if rows.last.length + chunk.length > @max_column_width then rows.push chunk else rows.last.concat " "+chunk end
      }

      rows
    end

    def write
      m = []
      m.push bar
      m.push n
      m.push "    #{@title}".rjust(40)
      m.push n
      m.push n
      m.push bar
      unless @flags.keys.empty?
        m.push offset 2, *["| flag", "| info"].map(&:upcase)
        m.push bar
        @flags.each { |flag, info|
          if info.length > @max_column_width
            chunks = chunker info
            m.push row( @script, '', '--'+flag, chunks.shift )
            chunks.each { |chunk| m.push offset 3, chunk }
            m.push n
          else
            m.push row(@script, '', '--'+flag, info)
            m.push n
          end
          
        }
      end
      m.push n
      unless @cmds.keys.empty?
        m.push bar
        m.push row *['', "| cmd", "| flag", "| info"].map(&:upcase)
        m.push bar
        @cmds.keys.each { |cmd|
          # add top level command
          m.push n
          if @cmds[cmd][:info].length > @max_column_width
            chunks = chunker @cmds[cmd][:info]
            m.push row(@script, cmd, '', chunks.shift)
            chunks.each { |chunk| m.push offset 3, chunk }
            m.push n
          else
            m.push row(@script, cmd, '', @cmds[cmd][:info])
            m.push n
          end

          # add flags for command
          @cmds[cmd][:flags].keys.each {|flag|
            if @cmds[cmd][:flags][flag].length > @max_column_width
              chunks = chunker @cmds[cmd][:flags][flag]
              m.push row( @script, cmd, '--'+flag, chunks.shift )
              chunks.each { |chunk| m.push offset 3, chunk }
              m.push n
            else
              m.push row(@script, cmd, '--'+flag, @cmds[cmd][:flags][flag] )
              m.push n
            end
          }

        }
        m.push bar
        m.push n
      end
      respond m.join('')
    end
  end
end






