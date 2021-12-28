class CV::ChMeta
  property index : Int32
  property sname : String
  property snvid : String
  property chidx : In32

  def initialize(argv : Array(String))
    @index = argv[0].to_i
    @sname = argv[1]
    @snvid = argv[2]
    @chidx = argv[3].to_i
  end

  def initialize(@index, @sname, @snvid, @chidx)
  end

  def to_s(io : IO)
    {@index, @sname, @snvid, @chidx}.join(IO, '\t')
  end
end

class CV::Nvchap
  CACHE = {} of Int64 => self

  CHDIR = "var/chtexts/_base"
  ::FileUtils.mkdir_p(CHDIR)

  def self.load!(nvinfo : Nvinfo)
    CACHE[nvinfo.id] ||= new(nvinfo)
  end

  getter nvinfo : Nvinfo
  getter ch_map : Array(ChMeta)

  def initialize(@nvinfo)
    @file = File.join(CHDIR, @nvinfo.bhash)

    if File.exists?(file)
      @ch_map = File.read_lines(file).map { |x| ChMeta.new(x.split('\t')) }
      @ch_map.sort_by!(x.index)
    end

    return unless @ch_map.empty? && (zseed = nvinfo.zseed_ids.sort.first?)
    zhbook = Zhbook.load!(nvinfo, zseed)

    nvinfo.update({
      cv_utime:      zhbook.utime,
      cv_chap_count: zhbook.chap_count,
    })

    @ch_map << ChMeta.new(1, zhbook.sname, zhbook.snvid, 1)
    self.save!
  end

  def save!
    File.write(@file, @ch_map.map(x.to_s).join('\n'))
  end

  def delete!(index : Int32, count : Int32 = 1)
    if (last = @ch_map.last?) && last.index < index
      @ch_map << ChMeta.new(index, last.sname, last.snvid, last.chidx + count)
    else
    end

    self.save!
  end

  def insert!(sname : String, snvid : String, index : Int32, count : Int32 = 1)
    @ch_map.reverse_each do |meta|
      if meta.index > index
        meta.index += count
        next
      end
    end

    self.save!
  end
end
