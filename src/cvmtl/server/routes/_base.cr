require "../../engine"

module MT
  abstract class BaseCtrl < ActionController::Base
    Log = Server::Log.for("controller")

    add_responder("*/*") { |io, result| io << result }
    add_responder("text/html") { |io, result| result.to_json(io) }
    add_responder("text/plain") { |io, result| io << result }

    # This makes it simple to match client requests with server side logs.
    # When building microservices this ID should be propagated to upstream services.
    @[AC::Route::Filter(:before_action)]
    def set_request_id
      request_id = UUID.random.to_s
      Log.context.set(client_ip: client_ip, request_id: request_id)
      response.headers["X-Request-ID"] = request_id

      # If this is an upstream service, the ID should be extracted from a request header.
      # request_id = request.headers["X-Request-ID"]? || UUID.random.to_s
      # Log.context.set client_ip: client_ip, request_id: request_id
      # response.headers["X-Request-ID"] = request_id
    end

    @[AC::Route::Filter(:before_action)]
    def set_date_header
      response.headers["Date"] = HTTP.format_time(Time.utc)
    end

    # handle common errors at a global level
    # this covers no acceptable response format and not an acceptable post format
    @[AC::Route::Exception(ActionController::Route::NotAcceptable, status_code: HTTP::Status::NOT_ACCEPTABLE)]
    @[AC::Route::Exception(AC::Route::UnsupportedMediaType, status_code: HTTP::Status::UNSUPPORTED_MEDIA_TYPE)]
    def bad_media_type(error)
      {
        error:   error.message,
        accepts: error.accepts,
      }
    end

    # this covers a required paramater missing and a bad paramater value / format
    @[AC::Route::Exception(AC::Route::Param::MissingError, status_code: HTTP::Status::BAD_REQUEST)]
    @[AC::Route::Exception(AC::Route::Param::ValueError, status_code: HTTP::Status::BAD_REQUEST)]
    def invalid_param(error)
      {
        error:       error.message,
        parameter:   error.parameter,
        restriction: error.restriction,
      }
    end
  end
end
