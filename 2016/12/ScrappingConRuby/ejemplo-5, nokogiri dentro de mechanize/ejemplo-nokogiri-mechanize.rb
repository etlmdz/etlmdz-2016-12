require 'nokogiri'
require 'open-uri'

require 'mechanize'

require 'pry'
require 'pry-byebug'

puts "Generador de mapas conceptuales en Ruby"
puts "Módulo extractor de imagenes relacionadas"
puts "Versión 0.1 - Copyleft (2016) Sergio A. Alonso aka <pancutan>"
puts ""
puts "Apuntado a sección div de efemerides presente en pagina principal de Wikipedia"
puts ""
puts "Instalación: "
puts "1- Instale ruby, gem y la gema bundler"
puts "2- Instale las librerias mediante el comando bundle"
puts ""
puts "Uso: "
puts "ruby ejemplo-nokogiri-mechanize.rb"
puts ""
puts "Para debuggear, descomente la linea binding.pry, y"
puts "Use los términos continue, next, break o help para continuar"
puts ""
puts "Presione Enter para comenzar"
gets
# binding.pry


agent = Mechanize.new

# Ya con esto solito obtengo un monton de cosas, links mayormente
page = agent.get('https://es.wikipedia.org/wiki/Wikipedia:Portada')

# Con esto puedo usar a Nokogiri en "search" para traer cosas especificas
# Aca esta exacto el ejemplo anterior de busqueda por css
page = agent.get('https://es.wikipedia.org/wiki/Wikipedia:Portada').search("#mw-content-text > table:nth-child(3) > tr:nth-child(1) > td:nth-child(3) > table:nth-child(1) > tr:nth-child(4) > td:nth-child(1) > ul:nth-child(2) > li")
# Con esto obtengo las Efemerides

puts "Efemerides de Wikipedia al #{Time::now::day}/#{Time::now::month}"
page.each do |p|
  puts p.text
end

# O versión refactorizada, util para cuando se trabaja con irb o pry:
# page.map {|p| p.text}

page.each do |p|
  # Para mostrar los links que lleva ese parrafo adentro, uso .to_s en lugar de .text
  # Ejemplo: "<li>\n<b><a href=\"/wiki/1886\" title=\"1886\">1886</a></b>.— Nace <b><a href=\"/wiki/Diego_Rivera\" title=\"Diego Rivera\">Diego Rivera</a></b>, <a href=\"/wiki/Muralismo_mexicano\" title=\"Muralismo mexicano\">muralista</a> y <a href=\"/wiki/Pintor\" title=\"Pintor\">pintor</a> <a href=\"/wiki/M%C3%A9xico\" title=\"México\">mexicano</a>.</li>"
  # En lugar de ponerme a crear una mini funcion que extraiga los <a href
  # me conviene crear otra instancia de Nokogiri y extraerlos directamente
  urls = Nokogiri(p.to_s)


  # Puesto que hay muchos <a href adentro, los recorro con un iterador
  urls.search('a').each do |a|
    # Ejemplo: "1886.— Nace Diego Rivera, muralista y pintor mexicano."
    puts p.text
    puts "Imagenes relacionadas a esta noticia:"

    # Ejemplo
    # a.attribute_nodes[0] equivale a
    # (Attr:0x2317d18 { name = "href", value = "/wiki/1965" })
    #
    # Ejemplo: "/wiki/Diego_Rivera"
    resto_de_la_url = a.attribute_nodes[0].value
    wikiscrapper = Mechanize.new
    link_relacionado = wikiscrapper.get("https://es.wikipedia.org" + resto_de_la_url)

    # Una vez que he escrpaeado las sub urls de esas efemerides, me traigo
    # las urls de las imagenes
    # Versión refactorizada:
    # link_relacionado.search("img").map { |atributo| puts atributo.attr('src')}
    link_relacionado.search("img").each do |atributo|
      puts atributo.attr('src')
      `wget http:#{atributo.attr('src')}`

      siesta = 4
      puts "Frenando el robot a #{siesta} segundos por link"
      sleep siesta
    end

    puts ""
  end # urls.search('a').each do |a|

end # page.each do |p|


