module CV
  class HTMLException < Exception
    getter status_code : Int32 = 500
  end

  class NotFound < HTMLException
    @status_code = 404
  end

  class BadRequest < HTMLException
    @status_code = 400
  end

  class Unauthorized < HTMLException
    @status_code = 401
  end
end
