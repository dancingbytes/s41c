module S41C

  module Utils

    def to_bin(str)
      str.force_encoding("BINARY")
    end

    def to_utf8(str)
      str.force_encoding("UTF-8")
    end

  end # Utils

end # S41C
