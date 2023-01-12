require "./base_pipe"

class CV::Pipe::Error < CV::BasePipe
  def call(context : HTTP::Server::Context)
    raise NotFound.new(context.request.path) unless context.valid_route?
    call_next(context)
  rescue ex : HttpError
    set_response(context.response, ex, ex.status_code)
    # Log.error(exception: ex) { "Error: #{ex.status_code}".colorize(:red) }
  rescue ex
    set_response(context.response, ex, 500)
    Log.error(exception: ex) { "Error: 500".colorize(:red) }
  end

  def set_response(response : HTTP::Server::Response, ex : Exception, status_code : Int32)
    response.headers["Content-Type"] = "text/plain"
    response.status_code = status_code
    response.print(ex.message)
  end
end
