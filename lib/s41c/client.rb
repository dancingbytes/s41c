# encoding: utf-8

module S41C

  class Client

    include S41C::Utils

    def initialize(host='localhost', port=1421)
      require 'net/telnet'

      @host, @port = host, port
      @prompt = /^\+OK/n
      @errors = []

    end # initialize

    def login(username, password = nil)
      @login = username.nil? || username.empty? ? nil : username
      @password = password

      self
    end # login

    def errors
      @errors
    end # errors

    def ping
      cmd "ping"
    end # ping

    def disconnect
      cmd "disconnect"
    end # disconnect

    def shutdown
      cmd "shutdown"
    end # shutdown

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
    end # conn

    def cmd(str)
      return @errors unless conn
      parse @client.cmd(to_bin(str))
    end # cmd

    def parse(response)
      resp = to_utf8(response)
      resp.lines.first.chomp
    end # parse

  end # Client

end # S41C
