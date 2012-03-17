# encoding: utf-8

module S41C

  require 'win32ole'
  require 'socket'

  class Server

    def initialize(host='localhost', port=1421, log_file=nil)
      @host, @port = host, port
      @logger = log_file ? ::STDOUT.reopen(log_file, 'a') : ::STDOUT
      @ole_object = 'V77.Application'

      ["INT", "TERM"].each do |signal|
        Kernel::trap(signal) {
        log "\n*** Exiting"
        exit
        }
      end
    end # initialize

    def ole_object(name)
      @ole_object = name
    end # ole_object

    def at_exit(&block)
      Kernel::at_exit do
        yield
      end
    end # at_exit

    def start
      server = TCPServer.open(@host, @port)

      log "*** Server has been started on #{@host}:#{@port}"
      log "*** Ctrl+C for stopping"

      loop do

        begin
          session = server.accept_nonblock
        rescue IO::WaitReadable, Errno::EINTR
          IO.select([server])
          retry
        end

        session.print "Welcome\r\n"

        loop {
          attrs = S41C::Utils.to_utf8(session.gets || '').chomp.split('|')
          cmd = attrs.shift
          case cmd
          when "connect"
            session.puts S41C::Utils.to_bin(connect_to_1c(attrs))
            session.puts "+OK"
          when "create"
            session.puts S41C::Utils.to_bin(create(attrs))
            session.puts "+OK"
          when "eval_expr"
            session.puts S41C::Utils.to_bin(eval_expr(attrs))
            session.puts "+OK"
          when "invoke"
            session.puts S41C::Utils.to_bin(invoke(attrs))
            session.puts "+OK"
          when "disconnect"
            session.puts "Goodbye"
            session.close
          break
          else
            session.puts "Bad command"
            session.puts "+OK"
          end
        }

      end
    end # start

    private

    def log(msg)
      @logger.puts msg
      @logger.flush
    end # log

    def connect_to_1c(attrs)
      @conn.ole_free unless @conn.nil?
      options = attrs.shift || ''
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

    def create(attrs)
      return "Error: not connected" unless @conn
      obj_name = attrs.shift || ''
      begin
        @obj = @conn.CreateObject(obj_name)
        "Created"
      rescue => e
        "Error: #{e.message}"
      end
    end

    def eval_expr(attrs)
      return "Error: not connected" unless @conn
      expr = attrs.shift || ''
      begin
        @conn.invoke("EvalExpr", expr).to_s
      rescue => e
        "Error: #{e.message}"
      end
    end

    def invoke(attrs)
      return "Error: working object not found. You must create it before" unless @conn
      begin
        @obj.invoke(*attrs).to_s.encode("UTF-8", "IBM866", :invalid => :replace, :replace => "?")
      rescue => e
        "Error: #{e.message}"
      end
    end

  end # Server

end # S41C
