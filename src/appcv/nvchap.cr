class CV::Nvchap
  CACHE = {} of Int64 => self

  CHDIR = "var/chtexts/chivi"
  ::FileUtils.mkdir_p(CHDIR)

  def self.load!(nvinfo : Nvinfo)
    CACHE[nvinfo.id] ||= new(nvinfo)
  end

  getter nvinfo : Nvinfo

  def initialize(@nvinfo)
    @file = File.join(CHDIR, @nvinfo.bhash)

    if File.exists?(file)
      @ch_map = File.read_lines(file).map { |x| ChMeta.new(x.split('\t')) }
      @ch_map.sort_by!(x.index)
    end

    return unless @ch_map.empty? && (zseed = nvinfo.zseed_ids.sort.first?)
    zhbook = Zhbook.load!(nvinfo, zseed)

    nvinfo.update({cv_utime: zhbook.utime, cv_chap_count: zhbook.chap_count})
    ChList.dup_to_local!(zhbook.sname, zhbook.snvid, nvinfo.bhash)
  end

  # def delete!(index : Int32, count : Int32 = 1)
  #   if (last = @ch_map.last?) && last.index < index
  #     @ch_map << ChMeta.new(index, last.sname, last.snvid, last.chidx + count)
  #   else
  #   end

  #   self.save!
  # end

  # def insert!(sname : String, snvid : String, index : Int32, count : Int32 = 1)
  #   @ch_map.reverse_each do |meta|
  #     if meta.index > index
  #       meta.index += count
  #       next
  #     end
  #   end

  #   self.save!
  # end

  PAGES = RamCache(Int64, Array(ChInfo)).new(2048, 6.hours)

  def chpage(pgidx : Int32)
    PAGES.get(nvinfo.id << 6 | pgidx) do
      yield_meta(pgidx) do |index, snvid, sname, chidx|
        1
      end
    end
  end

  def yield_meta(pgidx : Int32)
    chidx = pgidx &* 32 + 1
    chmax = chidx + 31
    return unless index = @ch_map.bsearch_index(chidx)
    from = @ch_map.unsafe_fetch(index)

    while index < @ch_map.size
      diff = from.chidx - from.index
      upto = fetch(index + 1)

      from.index.upto(upto.index - 1) do |chidx|
        break if chidx > chmax
        yield chidx, from.snvid, from.sname, chidx + diff
      end

      from = upto
      index += 1
    end
  end

  private def fetch(index : Int32)
    @ch_map[index]? || ChMeta.new(nvinfo.chap_count + 1, from.sname, from.snvidt)
  end
end
