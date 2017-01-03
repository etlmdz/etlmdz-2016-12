#!/usr/bin/env bash
PATH="/home/salonso/.rvm/gems/ruby-2.3.0/bin:/home/salonso/.rvm/gems/ruby-2.3.0@global/bin:/home/salonso/.rvm/rubies/ruby-2.3.0/bin:/home/salonso/.rvm/gems/ruby-2.3.0/bin:/home/salonso/.rvm/gems/ruby-2.3.0@global/bin:/home/salonso/.rvm/rubies/ruby-2.3.0/bin:/usr/local/oracle/product/instantclient_32/12.1.0.2.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/home/salonso/.rvm/bin:/home/salonso/.rvm/bin"
GEM_HOME='/home/salonso/.rvm/gems/ruby-2.3.0'
GEM_PATH='/home/salonso/.rvm/gems/ruby-2.3.0:/home/salonso/.rvm/gems/ruby-2.3.0@global'
MY_RUBY_HOME='/home/salonso/.rvm/rubies/ruby-2.3.0'
IRBRC='/home/salonso/.rvm/rubies/ruby-2.3.0/.irbrc'
RUBY_VERSION='ruby-2.3.0'

date >> /home/salonso/scripts/fotobaires-scrapper/fotobaires-scrapper.log
date >> /home/salonso/scripts/fotobaires-scrapper/fotobaires-scrapper.err

echo "Controlando WS" >> /home/salonso/scripts/fotobaires-scrapper/fotobaires-scrapper.log
echo "Controlando WS" >> /home/salonso/scripts/fotobaires-scrapper/fotobaires-scrapper.err

#source ~/.rvm/scripts/rvm
source /home/salonso/.rvm/scripts/rvm

#A ver si por eso no encuentra el Libro1.xlsx
cd /home/salonso/scripts/fotobaires-scrapper

ruby fotobaires-scrapper.rb
