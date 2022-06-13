module CV
  class HttpError < Exception
    getter status_code : Int32 = 500
  end

  class NotFound < HttpError
    @status_code = 404
  end

  class BadRequest < HttpError
    @status_code = 400
  end

  class Unauthorized < HttpError
    @status_code = 401
  end
end
