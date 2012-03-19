# encoding: utf-8

module S41C

  class Server

    def initialize(host='localhost', port=1421, log_file=nil)
      require 'win32ole'

      @host, @port = host, port
      @logger = log_file ? ::STDOUT.reopen(log_file, 'a') : ::STDOUT
      @ole_object = 'V77.Application'
    end # initialize

    def set_login(username, password)
      @login = username
      @password = password
    end # login_info

    def ole_object=(name)
      @ole_object = name
    end # ole_object

    def at_exit(&block)
      ::Kernel::at_exit do
        yield
      end
    end # at_exit

    def start

      ["INT", "TERM"].each do |signal|
        ::Kernel::trap(signal) {
        log "\n*** Exiting"
        exit
        }
      end

      server = TCPServer.open(@host, @port)

      log "*** Server has been started on #{@host}:#{@port}"
      log "*** Ctrl+C for stopping"

      begin
        main_loop(server)
      rescue Errno::ECONNABORTED
        log "*** [#{Time.now}] Session aborted"
        retry
      end

    end # start

    private

    def read_response(session)
      S41C::Utils.to_utf8(session.gets || '').chomp
    end # read_response

    def log(msg)
      @logger.puts msg
      @logger.flush
    end # log

    def connect_to_1c(args)
      @conn.ole_free unless @conn.nil?
      options = args.shift || ''
      begin
        @conn = ::WIN32OLE.new('V77.Application') 
        res = @conn.Initialize(
          @conn.RMTrade, 
          options,
          ''
        )
        "Connected"
      rescue => e
        @conn.ole_free
        "Error: #{e.message}"
      end
    end

    def create(args)
      return "Error: not connected" unless @conn
      obj_name = args.shift || ''
      begin
        @obj = @conn.CreateObject(obj_name)
        "Created"
      rescue => e
        "Error: #{e.message}"
      end
    end

    def eval_expr(args)
      return "Error: not connected" unless @conn
      expr = args.shift || ''
      begin
        @conn.invoke("EvalExpr", expr).to_s
      rescue => e
        "Error: #{e.message}"
      end
    end

    def invoke(args)
      return "Error: working object not found. You must create it before" unless @conn
      begin
        @obj.invoke(*args).to_s.encode("UTF-8", "IBM866", :invalid => :replace, :replace => "?")
      rescue => e
        "Error: #{e.message}"
      end
    end

    def main_loop(server)
      loop do

        begin
          session = server.accept_nonblock
        rescue IO::WaitReadable, Errno::EINTR
          IO.select([server])
          retry
        end

        if @login
          res = true
          session.print "login"
          res = res && (read_response(session) == @login)
          if @password
            session.print "password"
            res = res && (read_response(session) == @password)
          end

          if res
            session.puts("success")
            session.puts("+OK")
          else
            session.puts "\n\rInvalid login or password"
            session.close
            next
          end # if
        end

        loop {
          args = S41C::Utils.to_utf8(session.gets || '').chomp.split("\0")
          cmd = args.shift
          case cmd
          when "connect"
            session.puts S41C::Utils.to_bin(connect_to_1c(args))
            session.puts "+OK"
          when "create"
            session.puts S41C::Utils.to_bin(create(args))
            session.puts "+OK"
          when "eval_expr"
            session.puts S41C::Utils.to_bin(eval_expr(args))
            session.puts "+OK"
          when "invoke"
            session.puts S41C::Utils.to_bin(invoke(args))
            session.puts "+OK"
          when "ping"
            session.puts "pong"
            session.puts "+OK"
          when "disconnect"
            session.puts "Goodbye"
            session.close
            break
          when "shutdown"
            session.puts "Server is going down now"
            session.close
            exit
          else
            session.puts "Bad command"
            session.puts "+OK"
          end
        }

      end
    end # main_loop

  end # Server

end # S41C
