module CvSession
  extend self

  DIR = "/var/chivi/session"
  Dir.mkdir_p(DIR)

  def ukey(id : Int32 = 0) : String
    int = Time.utc.to_unix
    int = int.unsafe_shl(20) ^ id
    int.to_s(base: 32)
  end

  def load(path : String)
    File.read(path) if File.exists?(path)
  end
end
