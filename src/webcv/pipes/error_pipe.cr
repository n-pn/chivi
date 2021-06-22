require "./base_pipe"

class CV::ErrorPipe < CV::BasePipe
  Log = ::Log.for("error")

  def call(context : HTTP::Server::Context)
    raise Amber::Exceptions::RouteNotFound.new(context.request) unless context.valid_route?
    call_next(context)
  rescue ex : Amber::Exceptions::Forbidden
    context.response.status_code = 403
    error = Amber::Controller::Error.new(context, ex)
    context.response.print(error.forbidden)
    Log.warn(exception: ex) { "Error: 403".colorize(:yellow) }
  rescue ex : Amber::Exceptions::RouteNotFound
    context.response.status_code = 404
    error = Amber::Controller::Error.new(context, ex)
    context.response.print(error.not_found)
    Log.warn(exception: ex) { "Error: 404".colorize(:yellow) }
  rescue ex : Exception
    context.response.status_code = 500
    error = Amber::Controller::Error.new(context, ex)
    context.response.print(error.internal_server_error)

    puts ex.message.colorize.red
    Log.error(exception: ex) { |ex| "Error: 500".colorize(:red) }
  end
end
