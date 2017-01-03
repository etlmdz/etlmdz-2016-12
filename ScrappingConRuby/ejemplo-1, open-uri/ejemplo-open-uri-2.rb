require 'open-uri'

require 'pry'
require 'pry-byebug'

# Use los términos continue, next, break o help para continuar
binding.pry

a = Array.new
open("http://www.ruby-lang.org/") do |f|
  f.each_line do |line|
    a.push line
  end
end

puts "Programa terminado"
