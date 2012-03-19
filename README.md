S41C (Socket for 1C)
======


TCP-socket-сервер и клиент для платформы "1С:Предприятие"

### Системные требования

* Microsoft Windows семейства NT (32bit)
* 1С:Предприятие v7
* [Ruby](http://rubyinstaller.org/downloads/) 1.9.3

### Установка

    gem install s41c

### Пример использования

Запустить сервер для 1C:Предприятия 7.7 (сетевая версия) на localhost:1421

    require 's41c'

    server = S41C::Server.new
    server.start

Или чуть сложнее: запустить сервер для 1С:Предприятия (локальная версия) на
127.0.0.1:2000, при подключении требовать логин "username" и пароль "password",
писать лог в c:\server.log  и записать время остановки 
сервера в файл

    require 's41c'

    server = S41C::Server.new('127.0.0.1', 2000, 'c:\server.log')
    server.set_login("username", "password")
    server.ole_object = 'V77L.Application'

    server.at_exit do
      File.open('c:\server_stoped_at.txt', 'w') { |f| f.puts Time.now }
    end

    server.start

После запуска с сервером можно общаться по telnet. Комманды, содержащие  не-ASCII
символы, должны быть utf8-строками переведенными в бинарный формат. В руби это 
можно сделать с помощью метода [String#force_encoding](http://ruby-doc.org/core-1.9.3/String.html#method-i-force_encoding):

    "utf8-строка".force_encoding("BINARY")
    => "utf8-\xD1\x81\xD1\x82\xD1\x80\xD0\xBE\xD0\xBA\xD0\xB0"

Отвечает сервер в том же формате, т.е. на стороне клиента ответ нужно
преобразовать в utf-строку:

    "utf8-\xD1\x81\xD1\x82\xD1\x80\xD0\xBE\xD0\xBA\xD0\xB0".force_encoding("UTF-8")
    => "utf8-строка"

В качесте разделителя используется utf'ный null-символ "\0". Список команд:

* "connect\0параметры_подключения" - подключиться к базе, например:
    
    "connect\0/d c:\\1c\\"

* "eval_expr\0команда" - выполнить команду
    
    "eval_expr\0ОсновнойЯзык()"

* "create\0Название.Объекта" - создать объект

    "create\0Справочник.Товары"

* "invoke\0НазваниеМетода\0параметры\0метода" - выполнить процедуру/функцию для объекта

    "invoke\0НайтиПоНаименованию\0Шляпа с полями"

* "disconnect" - отключиться от 1С
* "shutdown" - остановить сервер


