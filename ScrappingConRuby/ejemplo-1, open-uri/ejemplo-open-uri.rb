require 'open-uri'

require 'pry'
require 'pry-byebug'

require 'pry-rescue'

# Use los términos continue, next, break o help para continuar
binding.pry

i = 0 # Linea para explicar watchpoint
open("http://www.ruby-lang.org/") do |f|
    f.each_line {|line| p line}
end

puts "Programa finalizado"
