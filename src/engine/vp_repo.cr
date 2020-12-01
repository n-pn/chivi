require "./vp_dict"

class Chivi::VpRepo
  getter cwd : String
  getter env : String

  getter hanviet : VpDict { load_dict("hanviet") }

  def initialize(@cwd, @env)
    @bdic_dir = File.join(@cwd, "bdics")
    FileUtils.mkdir_p(@bdic_dir)
  end

  def load_dict(name : String)
  end
end
