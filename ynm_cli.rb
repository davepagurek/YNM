#!/usr/bin/env ruby

require_relative "./ynm.rb"
interpreter = YNM::Interpreter.new("", Proc.new{|res| puts res.inspect})
loop do
  printf("> ")
  line = gets
  break if /^(exit|quit)/i.match(line)
  interpreter.add_input!(line)
  interpreter.run!
end

