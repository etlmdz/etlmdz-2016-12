require 'nokogiri'
require 'open-uri'

require 'pry'
require 'pry-byebug'

# Use los términos continue, next, break o help para continuar
binding.pry

html_data = open('https://es.wikipedia.org/wiki/Wikipedia:Portada').read
nokogiri_object = Nokogiri::HTML(html_data)
elements = nokogiri_object.css("#mw-content-text > table:nth-child(3) > tr:nth-child(1) > td:nth-child(3) > table:nth-child(1) > tr:nth-child(4) > td:nth-child(1) > ul:nth-child(2) > li").map {|m| m.text}
elements.each do |e|
  puts e
end
puts "Programa terminado"
