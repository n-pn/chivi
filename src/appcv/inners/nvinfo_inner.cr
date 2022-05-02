module CV::NvinfoInner
  def add_nvseed(zseed : Int32) : Nil
    return if self.zseeds.includes?(zseed)

    self.zseeds.push(zseed).sort!
    self.zseeds_column.dirty!
  end

  getter cvseed : Nvseed { Nvseed.upsert!(self, "chivi", self.bhash) }

  def set_genres(zgenres : Array(String), force = false) : Nil
    return unless force || self.igenres.empty? || self.igenres == [0]
    cvseed.update(bgenre: zgenres.join('\t'))

    self.igenres.clear
    self.vlabels.clear if force

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

  def set_bintro(lines : Array(String), force = false) : Nil
    return unless force || self.bintro.empty?
    cvseed.update(bintro: lines.join('\n'))
    self.bintro = BookUtil.cv_lines(lines, self.dname, :text)
  end

  def set_bcover(scover : String, force = false) : Nil
    return unless force || self.bcover.empty?
    cvseed.update(bcover: scover)
    self.bcover = UkeyUtil.digest32(scover, 8) + ".webp"
  end

  def set_utime(utime : Int64, force = false) : Int64?
    return unless force || utime > self.utime

    self.atime = utime if self.atime < utime
    self.utime = utime
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

  # recalculate
  def fix_scores!(voters : Int32, scores : Int32) : Nil
    self.voters = voters

    if voters < 10
      scores &+= (10 - voters) &* 45
      self.rating = scores // 10
    else
      self.rating = scores // voters
    end

    self.weight = scores + Math.log(self.view_count + 10).to_i
  end

  def fix_names!(bdict : String? = self.dname)
    self.btitle.regen!(bdict) if bdict

    self.bslug = bhash[0..5] + self.btitle.hslug[..-2]
    self.vname = self.btitle.vname

    self.save!
  end
end
