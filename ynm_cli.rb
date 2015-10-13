#!/usr/bin/env ruby

require_relative "./ynm.rb"
interpreter = YNM::Interpreter.new("", Proc.new do |res|
  puts "Returned #{res.nil? ? "nothin to see here" : res.to_s}"
end)
last = ""
loop do
  printf("> ")
  line = gets
  if line.gsub(/\s+/, "").length == 0
    line = last
  end
  break if /^(exit|quit)/i.match(line)
  interpreter.add_input!(line)
  interpreter.run!
  last = line
end

