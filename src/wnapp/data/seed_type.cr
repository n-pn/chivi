enum WN::SeedType
  Chivi
  Draft
  Avail
  Users
  Globs
  Other

  def read_privi(is_owner = false, base_privi = 2)
    case self
    when Draft then 1
    when Avail then 2
    when Chivi then 3
    when Users then is_owner ? 1 : base_privi
    else            3
    end
  end

  def edit_privi(is_owner = false)
    case self
    when Draft then 1
    when Avail then 2
    when Chivi then 3
    when Users then is_owner ? 2 : 4
    else            3
    end
  end

  def delete_privi(is_owner = false)
    case self
    when Globs then 3
    when Users then is_owner ? 2 : 4
    else            4
    end
  end

  def type_name
    case self
    when Chivi then "chính thức"
    when Draft then "tạm thời"
    when Avail then "tổng hợp"
    when Users then "cá nhân"
    when Globs then "bên ngoài"
    else            "đặc biệt"
    end
  end

  def self.parse(sname : String)
    fchar = sname[0]
    case
    when fchar == '!'      then Globs
    when fchar == '@'      then Users
    when sname == "~chivi" then Chivi
    when sname == "~draft" then Draft
    when sname == "~avail" then Avail
    else                        Other
    end
  end

  def self.read_privi(sname : String, uname : String, base_privi : Int32)
    parse(sname).read_privi(owner?(sname, uname), base_privi)
  end

  def self.edit_privi(sname : String, uname : String)
    parse(sname).edit_privi(owner?(sname, uname))
  end

  def self.delete_privi(sname : String, uname : String)
    parse(sname).delete_privi(owner?(sname, uname))
  end

  def self.owner?(sname : String, uname : String)
    sname == "@#{uname}"
  end
end
