require "./server/*"

port = 5601
host = "127.0.0.1"
server = AC::Server.new(port, host)

terminate = Proc(Signal, Nil).new do |signal|
  puts " > terminating gracefully"
  spawn { server.close }
  signal.ignore
end

# Detect ctr-c to shutdown gracefully
# Docker containers use the term signal
Signal::INT.trap &terminate
Signal::TERM.trap &terminate

# Start the server
server.run do
  puts "Server listening on #{server.print_addresses}"
end

# Shutdown message
puts "Server terminated\n"
