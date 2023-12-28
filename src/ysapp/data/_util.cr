require "json"

module YS::YsUtil
  extend self

  def self.read_zip(zip_path : String, filename : String, &)
    read_zip?(zip_path, filename) || yield
  end

  def self.read_zip?(zip_path : String, filename : String)
    return unless File.file?(zip_path)

    Compress::Zip::File.open(zip_path) do |zip|
      zip[filename]?.try(&.open(&.gets_to_end))
    end
  end

  def self.zip_data(zip_path : String, inp_path : String)
    response = `zip -rjyoq '#{zip_path}' '#{inp_path}'`
    raise response unless $?.success?
  end
end
