# encoding: utf-8

module S41C

  class Parser

    BLOCK_BEGINNERS = /module|class|def|begin|do|case|if|unless|{/
    BLOCK_ENDERS = /end|}/

    def initialize(block)
      sl = block.source_location
      @file, @start_line = sl.first, (sl.last)

      if @file[/\(irb\)/]
        @lines = IRB.CurrentContext.io.line(0..-1)
      else
        f = File.open(@file, 'r')
        @lines = f.lines.to_a
        f.close
        @start_line -= 1
      end # if

    end # new

    def parse
      raw = @lines[@start_line..-1]
      depth = 0
      @finish_line = @start_line

      raw.each_with_index do |line, index|

        depth += 1 if line[BLOCK_BEGINNERS]
        depth -= 1 if line[BLOCK_ENDERS]

        if depth == 0
          @finish_line = index
          break
        end #if

      end # each

      block = raw[0..@finish_line]

      block.first.sub!(/^.*#{BLOCK_BEGINNERS}/, '')
      block.last.sub!(/#{BLOCK_ENDERS}.*$/, '')

      block.join
    end # parse

  end # Parser

end # S41C
