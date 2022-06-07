require "./server/*"

port = ENV["M2_PORT"]?.try(&.to_i?) || 5502
host = ENV["M2_HOST"]? || "127.0.0.1"
server = ActionController::Server.new(port, host)

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
  puts "MtlV2 listening on #{server.print_addresses}"
end

# Shutdown message
puts "MtlV2 server terminated\n"
