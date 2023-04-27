require "compress/zip"
require "clear"

require "./_data"

Clear::Log.level = ::Log::Severity::Error if CV_ENV.production?
Clear::SQL.init(CV_ENV.database_url)

class Clear::Model::Converter::BytesConverter
  def self.to_column(x) : Bytes?
    case x
    when String     then x.hexbytes
    when Bytes, Nil then x
    else
      raise Clear::ErrorMessages.converter_error(x.class.name, "Bytes")
    end
  end

  def self.to_db(x : Bytes?)
    x
  end
end

Clear::Model::Converter.add_converter("Bytes", Clear::Model::Converter::BytesConverter)
