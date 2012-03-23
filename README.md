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

#### Сервер

Запустить сервер для 1C:Предприятия 7.7 (сетевая версия) на localhost:1421 
и искпользовать базу "C:\Base\"

    require 's41c'

    server = S41C::Server.new
    server.db('C:\Base\\')
    server.start

Или чуть сложнее: запустить сервер для 1С:Предприятия (локальная версия) на
127.0.0.1:2000, искпользовать базу "C:\Base\", при подключении требовать логин 
"username" и пароль "password",писать лог в c:\server.log  и записать время 
остановки сервера в файл

    require 's41c'

    server = S41C::Server.new('127.0.0.1', 2000, 'c:\server.log')
    server.ole_name = 'V77L.Application'
    server.db('C:\Base\\')

    server.login("username", "password")

    server.at_exit do
      File.open('c:\server_stoped_at.txt', 'w') { |f| f.puts Time.now }
    end

    server.start

#### Клиент

Скоро ...
