# encoding: utf-8

module S41C

  class Client

    def initialize(host='localhost', port=1421)
      require 'net/telnet'

      @host, @port = host, port
      @prompt = /^\+OK/n
      @errors = []

    end # initialize

    def login(username, password = nil)
      @login = username.nil? || username.empty? ? nil : username
      @password = password
    end # login

    def errors
      @errors
    end # errors

    def connect(options)
      cmd "connect\0#{options}"
    end # connect

    def ping
      cmd "ping"
    end # ping

    def eval_expr(expr)
      cmd "eval_expr\0#{expr}"
    end # eval_expr

    def create(obj_name)
      cmd "create\0#{obj_name}"
    end # create

    def invoke(method_name, *args)
      cmd "invoke\0#{method_name}\0#{args.join("\0")}"
    end # invoke

    def disconnect
      cmd "disconnect"
    end # disconnect

    def shutdown
      cmd "shutdown"
    end # shutdown

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
      parse @client.cmd(S41C::Utils.to_bin(str))
    end # cmd

    def parse(response)
      resp = S41C::Utils.to_utf8(response)
      res = []

      resp.each_line do |line|
        res << line.chomp unless line[@prompt]
      end # each_line

      res.count > 1 ? res : res.first
    end # parse

  end # Client

end # S41C

