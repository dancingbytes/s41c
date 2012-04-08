# encoding: utf-8

module S41C

  class Client

    include S41C::Utils

    # Создать инстанс клиента
    #
    # @param [ String ] адрес сервера
    # @param [ Integer ] порт сервера
    def initialize(host='localhost', port=1421)
      require 'net/telnet'
      require 's41c/parser'

      @host, @port = host, port
      @prompt = /^\+OK/n
      @errors = []

    end

    # Задать данные для авторизации
    #
    # @param [ String ] логин
    # @param [ String ] пароль
    def login(username, password = nil)
      @login = username.nil? || username.empty? ? nil : username
      @password = password

      self
    end

    # Возвращает массив ошибок
    #
    # @return [ Array ] массив ошибок
    def errors
      @errors
    end

    # Проверка соединения с сервером
    def ping
      cmd "ping"
    end

    # Отключиться от сервера
    def disconnect
      cmd "disconnect"
    end

    # Остановить сервер и отключиться от него
    def shutdown
      cmd "shutdown"
    end

    # Выполнить на сервере блок кода
    #
    # @param [ Hash ] переменные, которые будут доступны внутри блока
    # @param [ Proc ] блок кода
    #
    # @return [ String ] результат выполнения блока
    def request(vars = {}, &block)
      code = S41C::Parser.new(block).parse
      dump = Marshal.dump({vars: vars, code: code})

      self.eval dump
    end

    # Выполнить на сервере строку
    #
    # @param [ String ] строка кода
    #
    # @return [ String ] результат выполнения
    def eval(code)
      cmd "eval\0\n#{code}\nend_of_code"
    end

    private

    def conn
      return true if @client
      begin

        @client = Net::Telnet.new('Host' => @host, 'Port' => @port, "Prompt" => @prompt)

        if @login
          resp = @client.login(@login, @password)

          unless resp["success"]
            @errors << "Invalid login or password"
            return false
          end # unless
        end # if

        return true

      rescue Errno::ECONNREFUSED => e
        @errors << e.message
        return false
      end
    end

    def cmd(str)
      return @errors unless conn
      parse @client.cmd(str)
    end

    def parse(response)
      resp = to_utf8(response)
      resp.lines.first.chomp
    end

  end

end
