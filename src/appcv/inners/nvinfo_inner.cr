module CV::NvinfoInner
  def add_nvseed(zseed : Int32) : Nil
    return if self.zseeds.includes?(zseed)
    self.zseeds.push(zseed).sort!
    self.zseeds_column.dirty!
  end

  def set_genres(zgenres : Array(String), force = false) : Nil
    return unless force || self.igenres.empty? || self.igenres == [0]
    self.igenres.clear

    GenreMap.zh_to_vi(zgenres).each do |vgenre|
      case igenre = GenreMap.map_int(vgenre)
      when .< 0 then self.vlabels << vgenre
      when .> 0 then self.igenres << igenre
      end
    end

    self.igenres << 0 if self.igenres.empty?
    self.vlabels_column.dirty!
    self.igenres_column.dirty!
  end

  def set_zintro(lines : Array(String), force = false) : Nil
    return unless force || self.bintro.empty?
    vintro = BookUtil.convert(lines, self.bhash)
    set_vintro(vintro.join("\n"), force: true)
  end

  def set_vintro(vintro : String, force = false) : Nil
    self.bintro = vintro if force || self.bintro.empty?
  end

  def set_covers(cover : String, force = false) : Nil
    return unless force || self.scover.empty?
    self.scover = cover
    self.bcover = UkeyUtil.digest32(cover, 8) + ".webp"
  end

  def set_bcover(cover : String, force = false) : Nil
    self.bcover = bcover if force || self.bcover.empty?
  end

  def set_utime(utime : Int64, force = false) : Int64?
    return unless force || utime > self.utime
    self.atime = utime if self.atime < utime
    self.utime = utime
  end

  def update_utime(utime : Int64) : Nil
    self.save! if set_utime(utime)
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

  # recalculate
  def fix_scores!(voters : Int32, scores : Int32) : Nil
    self.voters = voters

    if voters < 30
      scores &+= (30 - voters) &* 45
      self.rating = scores // 30
    else
      self.rating = scores // voters
    end

    self.weight = scores + Math.log(self.view_count + 10).to_i
  end

  def fix_names!(bdict : String? = self.dname)
    self.btitle.regen!(bdict) if bdict
    self.vname = self.btitle.vname

    self.bslug = self.btitle.hslug[1..] + bhash[0..3]
    self.save!
  end
end
