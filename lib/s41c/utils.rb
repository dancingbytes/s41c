# encoding: utf-8

module S41C

  module Utils

    def to_bin(str)
      str.to_s.force_encoding("BINARY")
    end

    def to_utf8(str)
      return unless str.is_a?(String)
      if str.encoding.to_s == "IBM866"
        str.to_s.encode("UTF-8", "IBM866", :invalid => :replace, :replace => "?")
      else
        str.to_s.force_encoding("UTF-8")
      end
    end

    def get_1c_id(obj)
      return false unless @ole

      str_id = @ole.invoke('ЗначениеВСтрокуВнутр', obj)
      escaped_str_id = "\"#{str_id.gsub('"', '""')}\""

    end # get_1c_id

  end # Utils

end # S41C
