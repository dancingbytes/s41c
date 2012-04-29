# encoding: utf-8

module S41C

  class Server

    include S41C::Utils

    # Создать инстанс сервера
    #
    # @param [ String ] адрес, на котором будет запущен сервер
    # @param [ Integer ] порт
    # @param [ String ] лог-файл
    def initialize(host='0.0.0.0', port=1421, log_file=nil)
      require 'socket'
      require 'win32ole'

      @host, @port = host, port
      @logger = log_file ? ::STDOUT.reopen(log_file, 'a') : ::STDOUT
      @ole_name = 'V77.Application'

      @local_storage = {}

    end

    # Задать данные для авторизации подключающихся клиентов
    #
    # @param [ String ] логин
    # @param [ String ] пароль
    def login(username, password)
      @login = username
      @password = password

      self
    end

    # Задать IP-адреса, с которых разрешено подключение
    #
    # @param [ Array ] список адресов
    def white_list(*args)
      @white_list = args
    end

    # Параметры подключения к базе 1C
    #
    # @params [ String ] база
    # @params [ String ] имя пользователя
    # @params [ String ] пароль пользователя
    def db(database, user=nil, password=nil)
      @conn_options = "/d #{database}"
      @conn_options << " /n #{user}" if user
      @conn_options << " /p #{password}" if password

      self
    end

    # Название ole-объекта, который будет использоваться для подключения к 1С
    #
    # @param [ String ] название ole-объекта
    def ole_name=(name)
      @ole_name = name

      self
    end

    # Задать блок кода, который будет выполнен при выключении сервера
    #
    # @param [ Proc ] блок кода
    def at_exit(&block)
      ::Kernel::at_exit do
        yield
      end

      self
    end

    # Запустить сервер
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

    end

    private

    def read_response(session)
      (session.gets || '').chomp
    end

    def log(msg)
      @logger.puts msg
      @logger.flush
    end

    def connect_to_1c
      begin
        @ole = ::WIN32OLE.new(@ole_name)
        @conn = @ole.Initialize(
          @ole.RMTrade, 
          (@conn_options),
          'NO_SPLASH_SHOW'
        )
      rescue WIN32OLERuntimeError => e
        @conn = nil
        log "*** Error: #{to_utf8(e.message)}"
      rescue => e
        log "*** Error: #{e.message} from #{__FILE__}:#{__LINE__}"
      end
    end

    def eval_code(dump)
      return "Error: not connected to 1C" unless @conn

      S41C::Sandbox.new(@ole, @local_storage, dump).eval_code
    end

    def main_loop(server)
      loop do

        begin
          session = server.accept_nonblock
        rescue IO::WaitReadable, Errno::EINTR
          IO.select([server])
          retry
        end

        if @white_list && !@white_list.include?(session.remote_address.ip_address)
          session.close
          next
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
            dump = ""
            while !(part = session.gets)['end_of_code']
              dump << part
            end
            session.puts to_bin(eval_code(dump))
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
    end

  end

end
