require "./srv_mt/config"
require "./srv_mt/routes"

port = ENV["MT_PORT"]?.try(&.to_i?) || 5502
host = ENV["MT_HOST"]? || "127.0.0.1"
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
  puts "mt_v2 listening on #{server.print_addresses}"
end

# Shutdown message
puts "mt_v2 server terminated\n"
