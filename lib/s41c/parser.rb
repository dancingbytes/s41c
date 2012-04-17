# encoding: utf-8

module S41C #:nodoc

  class Parser #:nodoc

    BLOCK_BEGINNERS = /\b(module|class|def|begin|do|case|if|unless)\b|{/
    BLOCK_ENDERS = /\bend\b|}/

    #:nodoc
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

    #:nodoc
    def parse
      raw = @lines[@start_line..-1]
      depth = 0
      code = []

      raw.each_with_index do |line, index|

        line.gsub!(/^\r\n/,'')
        line.gsub!(/\r\n$/,'')

        depth += line.scan(BLOCK_BEGINNERS).count
        depth -= line.scan(BLOCK_ENDERS).count

        code << line

        break if depth == 0

      end # each

      code.first.sub!(/^.*#{BLOCK_BEGINNERS}/, '')
      code.last.sub!(/#{BLOCK_ENDERS}.*$/, '')

      code.delete_if{|el| el.empty?}.join(';')
    end

  end

end
