require 'nokogiri'
require 'open-uri'

require 'mechanize'

require 'pry'
require 'pry-byebug'

require 'pry-rescue'

agent = Mechanize.new

# Borrar cookies.yaml para entrar nuevamente al login
if File.exist?("cookies.yaml")
  agent.cookie_jar.load("cookies.yaml")
  agent.get("http://localhost:3000/users")
  # Ahora si, comenzar a escrapear sin ser rebotados al login cada vez
else
  login_page = agent.get("http://localhost:3000/login")
  form  = login_page.form_with(action: "/login")
  form.email = "sergio@eim.esc.edu.ar"
  form.password = "AndaLaOsa2016"
  home_page = agent.submit(login_page.forms.first, login_page.forms.first.buttons.first)
  agent.cookie_jar.save_as 'cookies.yaml', :session => true, :format => :yaml

  puts ""
end

puts "Programa terminado"
