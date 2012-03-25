# encoding: utf-8

module S41C

  module Utils

    # Переводит строку в бинарное представление
    #
    # @param [ String ] строка в utf-8
    #
    # @return [ String ] строка в бинарном представлении
    def to_bin(str)
      str.to_s.force_encoding("BINARY")
    end

    # Переводит строку в utf-8
    #
    # @param [ String ] бинарная строка или строка из 1С
    #
    # @return [ String ] строка в utf-8
    def to_utf8(str)
      return unless str.is_a?(String)
      if str.encoding.to_s == "IBM866"
        str.to_s.encode("UTF-8", "IBM866", :invalid => :replace, :replace => "?")
      else
        str.to_s.force_encoding("UTF-8")
      end
    end

    # Обертка над 1С-функцией "ЗначениеВСтрокуВнутр"
    #
    # @param [ Object ] объект 1С
    #
    # @return [ String ] идентификатор объекта
    def get_1c_id(obj)
      return false unless @ole

      str_id = @ole.invoke('ЗначениеВСтрокуВнутр', obj)
      escaped_str_id = "\"#{str_id.gsub('"', '""')}\""

    end

  end

end
