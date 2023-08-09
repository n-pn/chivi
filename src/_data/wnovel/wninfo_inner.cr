require "../../_util/hash_util"

module CV::WninfoInner
  def set_genres(zgenres : Array(String), force = false) : Nil
    return unless force || self.igenres.empty? || self.igenres == [0]
    set_vgenres(GenreMap.zh_to_vi(zgenres), force: force)
  end

  def set_vgenres(vgenres : Array(String), force = false) : Nil
    return unless force || self.igenres.empty? || self.igenres == [0]

    self.igenres.clear
    self.vlabels.clear if force

    vgenres.each do |vgenre|
      case igenre = GenreMap.map_int(vgenre)
      when .< 0 then self.vlabels << vgenre
      when .> 0 then self.igenres << igenre
      end
    end

    self.igenres << 0 if self.igenres.empty?
    self.vlabels_column.dirty!
    self.igenres_column.dirty!
  end

  def set_bcover(link : String, force = false) : Nil
    return unless force || self.scover.empty?
    self.bcover = "" unless self.scover == link
    self.scover = link
  end

  def cache_cover(link = self.scover, persist : Bool = true) : Nil
    return if link.empty?

    bcover = HashUtil.digest32(link, 8)
    `./bin/bcover_cli -f -i "#{link}" -n "#{bcover}"`

    self.bcover = $?.success? ? "#{bcover}.webp" : ""
    self.save! if persist
  end

  def set_utime(utime : Int64, force = false) : Int64?
    return unless force || utime > self.utime
    self.utime = utime
    self.atime = utime if self.atime < utime
  end

  def update_utime(utime : Int64, force = false) : Nil
    self.save! if set_utime(utime, force: force)
  end

  def bump!(time = Time.utc)
    update!(atime: time.to_unix)
  end

  def set_status(status : Int32, force = false) : Nil
    return unless force || self.status < status || self.status == 3 && status > 0
    self.status = status
  end

  def set_shield(shield : Int32, force = false) : Nil
    self.shield = shield if force || shield > self.shield
  end

  def set_zscores!(zvoters : Int32, zrating : Int32)
    self.zvoters = zvoters
    self.zrating = zrating

    self.fix_xscores!
  end

  def set_vscores!(vvoters : Int32, vrating : Int32)
    self.vvoters = vvoters
    self.vrating = vrating

    self.fix_xscores!
  end

  def fix_xscores!
    self.voters = self.zvoters &+ self.vvoters
    scores = self.zvoters &* self.zrating &+ self.vvoters &* self.vrating

    if self.voters < 10
      scores &+= (10 &- self.voters) &* 45
      self.rating = scores // 10
    else
      self.rating = scores // self.voters
    end

    self.weight = scores &+ Math.log(self.view_count &+ 10).to_i
  end

  def set_bslug(hslug : String)
    tokens = hslug.split('-', remove_empty: true)

    if tokens.size > 8
      tokens.truncate(0, 8)
      tokens[7] = ""
    end

    self.bslug = tokens.join('-')
  end
end
