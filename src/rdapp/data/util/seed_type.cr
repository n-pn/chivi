enum WN::SeedType
  Chivi
  Avail
  Other

  def plock
    case self
    when Avail then 2
    when Chivi then 3
    else            3
    end
  end

  def type_name
    case self
    when Avail then "Tổng hợp"
    when Chivi then "Chính thức"
    else            "Bên ngoài"
    end
  end

  def self.parse(sname : String)
    case sname
    when "~chivi" then Chivi
    when "~avail" then Avail
    else               Other
    end
  end
end
