# encoding: utf-8

module S41C

  class Server

    include S41C::Utils

    def initialize(host='localhost', port=1421, log_file=nil)
      require 'socket'
      require 'win32ole'

      @host, @port = host, port
      @logger = log_file ? ::STDOUT.reopen(log_file, 'a') : ::STDOUT
      @ole_name = 'V77.Application'

    end # initialize

    def login(username, password)
      @login = username
      @password = password

      self
    end # login

    def db(database, user=nil, password=nil)
      @conn_options = "/d #{database}"
      @conn_options << " /n #{user}" if user
      @conn_options << " /p #{password}" if password

      self
    end # db

    def ole_name=(name)
      @ole_name = name

      self
    end # ole_name=

    def at_exit(&block)
      ::Kernel::at_exit do
        yield
      end

      self
    end # at_exit

    def start

      ["INT", "TERM"].each do |signal|
        ::Kernel::trap(signal) {
        log "\n*** Exiting"
        exit
        }
      end

      connect_to_1c

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
      to_utf8(session.gets || '').chomp
    end # read_response

    def log(msg)
      @logger.puts msg
      @logger.flush
    end # log

    def connect_to_1c
      begin
        @ole = ::WIN32OLE.new(@ole_name)
        @conn = @ole.Initialize(
          @ole.RMTrade, 
          (@conn_options),
          ''
        )
      rescue WIN32OLERuntimeError => e
        @conn = nil
        log "*** Error: #{to_utf8(e.message)}"
      rescue => e
        log "*** Error: #{e.message} from #{__FILE__}:#{__LINE__}"
      end
    end

    def eval_code(code)
      return "Error: not connected" unless @conn

      S41C::Sandbox.new(@ole, code).eval_code
    end # eval_code

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
          args = read_response(session).split("\0")
          cmd = args.shift
          case cmd
          when "eval"
            code = ""
            while !(part = session.gets)['end_of_code']
              code << to_utf8(part)
            end
            session.puts to_bin(eval_code(code))
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
            session.puts "Bad command: `#{cmd}`"
            session.puts "+OK"
          end
        }

      end
    end # main_loop

  end # Server

end # S41C
