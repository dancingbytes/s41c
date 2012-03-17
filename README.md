S41C (Socket for 1C)
======


TCP-socket-сервер и клиент для платформы "1С:Предприятие"

### Системные требования

* Microsoft Windows семейства NT (32bit)
* [Ruby](http://rubyinstaller.org/downloads/) 1.9.3 и выше


### Пример использования

Запустить сервер для 1C:Предприятия 7.7 на localhost:1421

    require 's41c'

    server = S41C::Server.new
    server.start

Или чуть сложнее: запустить сервер для 1С:Предприятия (локальная версия) на
127.0.0.1:2000 и записать время остановки сервера в файл

    require 's41c'

    server = S41C::Server.new('127.0.0.1', 2000, 'c:\server.log')
    server.ole_object = 'V77L.Application'

    server.at_exit do
      File.open('c:\server_stoped_at.txt', 'w') { |f| f.puts Time.now }
    end

    server.start

После запуска с сервером можно общаться по telnet коммандами:

* connect - подключиться к 1С
* eval_expr - выполнить комманду
* create - создать объект
* invoke - выполнить процедуру/функцию для объекта
* disconnect - отключиться от 1С
* shutdown - остановить сервер
