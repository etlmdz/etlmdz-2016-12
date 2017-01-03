require 'nokogiri'
require 'open-uri'

require 'pry'
require 'pry-byebug'

# Use los términos continue, next, break o help para continuar
binding.pry

html_data = open('https://es.wikipedia.org/wiki/Wikipedia:Portada').read
nokogiri_object = Nokogiri::HTML(html_data)
elements = nokogiri_object.xpath("//body[@class='mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-4 ns-subject page-Wikipedia_Portada rootpage-Wikipedia_Portada skin-vector action-view']/div[@id='content']/div[@id='bodyContent']/div[@id='mw-content-text']/table[3]/tr/td[@class='MainPageBG'][2]/table/tr[4]/td[@id='wp-port']/ul/li").map {|v| v.text}

elements.each do |e|
  puts e
end

puts "Programa terminado"
