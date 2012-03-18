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
127.0.0.1:2000, писать лог в c:\server.log  и записать время остановки 
сервера в файл

    require 's41c'

    server = S41C::Server.new('127.0.0.1', 2000, 'c:\server.log')
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

Список команд:

* 'connect|параметры_подключения' - подключиться к базе, например:
    
    'connect|/d c:\1c\\'

* 'eval_expr|команда' - выполнить команду
    
    'eval_expr|ОсновнойЯзык()'

* 'create|Название.Объекта' - создать объект

    'create|Справочник.Товары'

* 'invoke|НазваниеМетода|параметры|метода' - выполнить процедуру/функцию для объекта

    'invoke|НайтиПоНаименованию|Шляпа с полями'

* 'disconnect' - отключиться от 1С
* 'shutdown' - остановить сервер


