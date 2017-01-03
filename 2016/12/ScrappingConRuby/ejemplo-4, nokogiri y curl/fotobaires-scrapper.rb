# fotobaires-scrapper
# Copyleft 2016 - Sergio Alonso - http://about.me/elbunker

require 'nokogiri' #start by loading the nokogiri gem
require 'open-uri' #this is required to open the URLs we are going to scrape
require 'pry'
require 'pry-byebug'

# Se lanzan con rescue en lugar de con ruby
require 'pry-rescue'
require 'pry-stack_explorer'

require 'mechanize'
require 'capybara/poltergeist'

# Leer / Grabar meta info de las fotos
# https://github.com/janfri/mini_exiftool
# sudo apt-get install libimage-exiftool-perl
require 'mini_exiftool'

# Conexion al \adfeatures
# https://github.com/johnae/sambal
# apt-get install smbclient
# Prueba si anda todo:
# smbclient \\\\10.38.11.11\\Fotografia -U UNOMEDIOS\\diariosadm%Lg3681Lg
# Para mas datos, consulte mi libro de Redes en www.eim.esc.edu.ar/incubadora
require 'sambal'

require 'active_record'


# binding.pry # Para clavar algun breakpoint al inicio

########################################################
# Comienzan funciones
# ######################################################

"excepcion".to_i

def llenarfoto(foto_ruta,foto_descripcion,foto_url)
  puts "Llenando #{foto_ruta}"
  puts "==> #{foto_descripcion}"

  photo = MiniExiftool.new foto_ruta

  # Esto lo ve el explorador de archivos de Windows: es util ponerlo en modo detalle
  # agregando la columna Titulo (boton derecho junto a tamaño, Tipo, etc)
  # para ver de que se tratan cada una de las fotos en na carpeta, de un vistazo
  photo.imagedescription = foto_descripcion

  # Esto lo ve el Photoshop
  # En pestaña Description, Author y tambien
  # en pestaña IPTC, Creator
  #photo.author           = 'Escrapeado por Sergio' # je
  photo.author           = foto_descripcion #redundante, para facilitar la tarea al programador

  # Esto tambien lo ve Photoshop
  # En pestaña Description, campo Description
  photo.description      = foto_url

  # Esto lo puedo setear, pero el Photoshop por ejemplo, no los ve
  # photo.caption_abstract = 'disponible4'
  # photo.url              = 'https://cablera.telam.com.ar' + foto_url[0][1]'

  photo.save
end

def scrapeame_esta(url)
  # binding.pry
  pagina_principal = Nokogiri::HTML(open(url)) #We are using both open-uri and nokogiri here.  Open-URI opens the URL and Nokogiri is parsing it so we can use its custom functions

  ##########################################################################
  # Bajando TODO

  # Esto no va a funcionar, el Apache usa referers y assets - usar wget
  # uri = URI.join( URL, src ).to_s # esta conformacion de url es mejor?
  # File.open(File.basename(uri),'wb'){ |f| f.write(open(uri).read) }

  #Me bajo toda la fucking url
  #puts "Obteniendo url, sacar el --quiet para mas detalles"
  #`wget -p -k --quiet #{url}`
  ##########################################################################

=begin
  ##########################################################################
  # Chequeando lo que se bajó contra lo que figura arriba, que no habia podido
  # bajar con File.open(File.basename(uri),'wb'){ |f| f.write(open(uri).read) }
  #
  Ejemplo de lo que se obtiene con
  algo = doc.css('img').map { |i| i['src'] }
=end

  enlace_imagen = 1
  enlace_texto_nota = 2
  primer_ajuste = 0
  # pagina principal: http://www.fotobaires.com/carga.php?carga=eventos.php&TIPO=1&titulo=Fotos+del+dia&sts=R
  # Es la hoja 1 con todas las noticias
  #binding.pry
  while enlace_imagen < (pagina_principal.css('a').map { |i| i['href'] }.size - 3)

    # Ejemplo de esta variable
    # http://www.fotobaires.com/carga.php?carga=evento.php&evento=18823&titulo=Evento+N%BA+00018823
    #                           carga.php?carga=evento.php&evento=18823&titulo=Evento+N%BA+00018823
    pagina_secundaria = pagina_principal.css('a').map { |i| i['href'] }[enlace_imagen]

    # Ajustando el cursor. La siguiente instruccion debe dar distinto de cero en su primer iteraccion
    # Por ejemplo tendría que devolver
    # (Text "BELGRANO VS ESTUDIANTES-SEGUNDA ENTREGA")
    if pagina_principal.css('a').map { |i| i }[enlace_imagen].child.text == "" and primer_ajuste == 0
      enlace_imagen = 2
      primer_ajuste = 1
    end
    texto_nota = pagina_principal.css('a').map { |i| i }[enlace_imagen].child.text

    # Primer noticia
    # http://www.fotobaires.com/carga.php?carga=evento.php&evento=18793&titulo=Evento+N%BA+00018793
    pagina_secundaria_url = "http://www.fotobaires.com/" + pagina_secundaria

    pagina_secundaria_procesada = Nokogiri::HTML(open(pagina_secundaria_url))
    #puts pagina_principal.css('b').map { |b| b }[0].child.child.text

    #A ver si con esto ya es suficiente...
    agent = Mechanize.new

    # Ejemplo estatico page = agent.get('http://www.fotobaires.com/carga.php?carga=bajar.php&antes=bajar_pre.php&TIPO=2&dir1=0002&dir2=000187&imagen=00018787-02.JPG')
    dir1 = pagina_secundaria_procesada.css('a')[0].attributes.map {|i| i }[1][1].value.split("'")[1]
    dir2 = pagina_secundaria_url[85..90] # ejemplo 000187
    imagen = pagina_secundaria_url[85..100] # 00018793

    # foto a extraer con curl
    #                http://www.fotobaires.com/carga.php?carga=bajar.php&antes=bajar_pre.php&TIPO=2&dir1=0001&dir2=000187&imagen=00018787-00.JPG
    #                http://www.fotobaires.com/carga.php?carga=bajar.php&antes=bajar_pre.php&TIPO=2&dir1=0002&dir2=000187&imagen=00018787-00.JPG
    url_a_extraer = "http://www.fotobaires.com/carga.php?carga=bajar.php&antes=bajar_pre.php&TIPO=2&dir1=#{dir1}&dir2=#{dir2}&imagen=#{imagen}-00.JPG"

    page = agent.get(url_a_extraer)

    formulario = page.forms[1]
    formulario.usuario_lg = "uno"
    formulario.clave_lg   = "coqui"

    pagina_respuesta = agent.submit(formulario)

    primer_cookie = pagina_respuesta.response["set-cookie"][13..55]
    segunda_cookie = pagina_respuesta.response["set-cookie"][71..113]
    begin
      #binding.pry
      tamano = 0
      tamano = pagina_respuesta.parser.document.children.map { |n| n }[1].children[4].children.map {|m| m}[5].children.map {|y| y }[0].text.split("&")[2].split("=")[1]
    rescue
      #binding.pry
      #puts "Linea para que pry no se pare en el end siguiente"
      tamano = 9959794 #generico
    end

    begin
      imagenes = 0
      imagenes = pagina_respuesta.parser.document.children.map { |n| n }[1].children[4].children.map {|m| m}[5].children.map {|y| y }[0].text.split("&")[3].split("%2F")[1]
    rescue
      #binding.pry
      imagenes = dir1
      #puts "Linea para que pry no se pare en el end siguiente"
    end

    # ejemplo estatico probado
    #cadena_curl = `curl --header 'Host: www.fotobaires.com' --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Referer: http://www.fotobaires.com/carga.php' --header 'Cookie: CookieDxf[0]=#{primer_cookie}; CookieDxf[1]=#{segunda_cookie}; CookieDxf[2]=0' --header 'Connection: keep-alive' --header 'Upgrade-Insecure-Requests: 1' 'http://www.fotobaires.com/carga.php?carga=descarga.php&TIPO=99&tamano=377422&x=imagenes%2F0001%2Fpriv%2F000187%2F00018791-00.JPG' -o '00018791-00.JPG' -L`
    cadena_curl = "curl --header 'Host: www.fotobaires.com' --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:48.0) Gecko/20100101 Firefox/48.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Referer: http://www.fotobaires.com/carga.php' --header 'Cookie: CookieDxf[0]=#{primer_cookie}; CookieDxf[1]=#{segunda_cookie}; CookieDxf[2]=0' --header 'Connection: keep-alive' --header 'Upgrade-Insecure-Requests: 1' 'http://www.fotobaires.com/carga.php?carga=descarga.php&TIPO=99&tamano=#{tamano}&x=imagenes%2F#{imagenes}%2Fpriv%2F#{dir2}%2F#{imagen}-00.JPG' -o '#{imagen}-00.JPG' -L"
    puts ""          # Mostrando
    puts enlace_imagen.to_s
    puts cadena_curl # Mostrando

    if File.exist? "#{imagen}-00.JPG"
      puts "Ya me lo bajé: no molestando al servidor"
    else
      # binding.pry
      `#{cadena_curl}` # Ejecutando

      llenarfoto("#{imagen}-00.JPG",texto_nota,url_a_extraer)

      begin
        puts "Subiendo al storage"

        # Ruta vieja
        # client = Sambal::Client.new(domain: 'UNOMEDIOS', host: '10.39.2.72', share: 'Archivos\\Fotografia', user: 'diariosadm', password: 'Lg3681Lg', port: 445)

        # Ejemplo pa' debuggear desde consola por si lo siguiente no camina
        # smbclient \\\\10.38.11.11\\Fotografia -U UNOMEDIOS\\diariosadm%Lg3681Lg

        # Ruta mas mejor, de acuerdo a Javier
        # Quitado en mi version casa #####################################################################
        # client = Sambal::Client.new(domain: 'UNOMEDIOS', host: '10.38.11.11', share: 'fotografia', user: '*********', password: '********', port: 445)
        # if client == nil
        #   # TODO: avisar por correo que no hay conexion
        #   puts "****************************"
        #   puts "No estoy llegando al Storage"
        #   puts "****************************"
        # end
        # client.cd("fotos_satelitales\\FOTO_BAIRES")

        #client.ls # returns hash of files

        # Debido a una exigencia de smbclient de proporcionar un nombre final
        # de archivo, uso un split para quedarme solo con el nombre

        # Uso la variable global $secuencia_archivo para facilitar la inspección de archivos
        # una vez subidos al storage
        #
        # Quitado en mi version casa ########################################################################
        # client.put("#{imagen}-00.JPG","#{imagen}-00.JPG")

      rescue
        # Quitado en mi version casa ########################################################################
        # client.close # closes connection
        # puts "Excepcion llegando al Storage"
      end #begin Subiendo al storage

    end #if File.exist? "#{imagen}-00.JPG"

    siesta = 40
    puts "Introduciendo demora de #{siesta} segundos"
    sleep siesta

    enlace_imagen = enlace_imagen + 2 #para mantenerse impar, esta variable no se vuelve a usar

  end # while enlace_imagen < pagina_principal.css('a').map { |i| i['href'] }.size

end #def scrapeame_esta(url)

puts "Iniciando #{Time::now}"
# Pagina 1
esta_url = "http://www.fotobaires.com/carga.php?carga=eventos.php&TIPO=1&titulo=Fotos+del+dia&sts=R"
puts "Escrapeando #{esta_url}"
scrapeame_esta(esta_url)

# Pagina 2
esta_url = "http://www.fotobaires.com/carga.php?carga=eventos.php&TIPO=1&sts=R&titulo=Fotos%20del%20dia&cate=&be=1&buscar_txt=&actual=1&vars=1"
puts "Escrapeando #{esta_url}"
scrapeame_esta(esta_url)

puts "Terminando #{Time::now}"
puts "Fin programa"
