require "../src/kernel/models/_models"
require "./migrate/*"

Clear.seed do
  puts "This is a seed"
end

Clear.with_cli do
  puts "Usage: crystal tasks/clear_cli.cr -- clear [args]"
  Clear::CLI.run
end
