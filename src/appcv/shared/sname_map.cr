module CV::SnameMap
  extend self

  MAP_INT = {
    "mixed" => 0,
    "chivi" => 0,

    "staff" => 1,
    "users" => 63,

    "zxcs_me" => 2,
    "hetushu" => 4,

    "bxwxorg" => 8,
    "69shu"   => 10,

    "xbiquge" => 16,
    "rengshu" => 18,

    "biqugee" => 20,
    "paoshu8" => 22,

    "biquyue" => 24,
    "ptwxz"   => 26,
    "xswang"  => 28,

    "biqu5200" => 32,
    "5200"     => 34,

    "shubaow" => 38,
    "duokan8" => 40,

    "sdyfcm"  => 50,
    "jx_la"   => 56,
    "zhwenpg" => 60,
  }

  def map_type(sname : String)
    case sname
    when "chivi", "mixed"
      0 # act as mirror
    when "users", "staff", "zxcs_me"
      1 # manual update
    when "jx_la", "zhwenpg", "shubaow", "sdyfcm", "duokan8"
      2 # dead remote
    when "paoshu8", "hetushu", "5200", "biqu5200", "ptwxz"
      3  # slow but still alive
    else # "bxwxorg", "69shu", "xbiquge", "rengshu", "biqugee"
      4  # fast remote
    end
  end

  MAP_INT.each_key do |sname|
    Dir.mkdir_p("var/chmetas/seeds/#{sname}")
    Dir.mkdir_p("var/chmetas/stats/#{sname}")
  end

  def alive_snames : Array(String)
    MAP_INT.keys.select { |sname| map_type(sname) > 2 }
  end

  def map_int(sname : Array(String))
    sname.map { |x| map_int(x) }.uniq!
  end

  def map_int(sname : String)
    MAP_INT[sname]? || 0
  end

  MAP_STR = MAP_INT.invert

  def map_str(int : Int32)
    MAP_STR[int] || "mixed"
  end

  def map_str(ints : Array(Int32))
    ints.map { |id| map_str(id) }
  end

  def map_uid(nvinfo_id : Int64, zseed = 0)
    (nvinfo_id << 6) | zseed
  end
end
