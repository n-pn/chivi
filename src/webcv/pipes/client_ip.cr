class CV::Pipe::ClientIp < CV::BasePipe
  def initialize(@header : String = "X-Forwarded-For")
  end

  def call(context : HTTP::Server::Context)
    if addresses = context.request.headers.get?(@header).try(&.first?)
      address = addresses.split(",").first
      context.client_ip = Socket::IPAddress.new(address, 0)
    end

    call_next(context)
  end
end
