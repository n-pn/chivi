class CV::Pipe::ClientIp < CV::BasePipe
  def initialize(header : String = "X-Forwarded-For")
    @headers = [header]
  end

  def initialize(@headers : Array(String))
  end

  def call(context : HTTP::Server::Context)
    @headers.each do |header|
      if addresses = context.request.headers.get?(header)
        address = addresses[0].split(",").first
        context.client_ip = Socket::IPAddress.new(address, 0)
      end
    end

    call_next(context)
  end
end
