module CV::NvinfoModel
  def add_nvseed(zseed : Int32) : Nil
    return if self.zseed_ids.includes?(zseed)
    self.zseed_ids.push(zseed).sort!
    self.zseed_ids_column.dirty!
  end

  def set_zgenre(genres : Array(String), force = false) : Nil
    set_genres(GenreMap.map_zh(genres), force: force)
  end

  def set_genres(genres : Array(String), force = false) : Nil
    return unless force || self.genre_ids.empty?
    genres_ids = GenreMap.map_id(genres)

    self.genre_ids = genres_ids.empty? ? [0] : genres_ids
    self.genre_ids_column.dirty!
  end

  def set_zintro(lines : Array(String), force = false) : Nil
    return unless force || self.zintro.empty?
    self.zintro = lines.join("\n")

    trans = BookUtil.convert(lines, self.bhash)
    set_vintro(trans.join("\n"), force: true)
  end

  def set_vintro(vintro : String, force = false) : Nil
    self.vintro = vintro if force || self.vintro.empty?
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

  def set_ys_scores(voters : Int32, rating : Int32) : Nil
    self.ys_voters = voters
    self.ys_scores = voters * rating
    fix_scores!
  end

  # trigger when user add a new book review
  def add_cv_rating(rating : Int32) : Nil
    self.cv_voters += 1
    self.cv_scores += rating
    fix_scores!
  end

  # trigger when user change book rating in his review
  def fix_cv_rating(new_rating : Int32, old_rating : Int32) : Nil
    return if new_rating == old_rating
    self.cv_scores = self.cv_scores - old_rating + new_rating
    fix_scores!
  end

  # recalculate
  def fix_scores! : Nil
    self.voters = self.cv_voters + self.ys_voters
    scores = self.cv_scores + self.ys_scores

    if self.voters < 30
      scores += (30 - self.voters) * 45
      self.rating = scores // 30
    else
      self.rating = scores // self.voters
    end

    self.weight = scores + Math.log(self.total_clicks + 10).to_i
  end

  def fix_names!
    self.vname = BookUtil.btitle_vname(self.zname, self.bhash)
    self.vslug = BookUtil.make_slug(self.vname)

    self.hname = BookUtil.hanviet(self.zname)
    self.hslug = BookUtil.make_slug(self.hname)

    self.bslug = self.hslug[1..] + bhash[0..3]
    self.save!
  end
end