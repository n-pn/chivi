enum WN::SeedType
  Chivi
  Draft
  Avail
  Other

  def plock
    case self
    when Draft then 1
    when Avail then 2
    when Chivi then 3
    else            3
    end
  end

  def type_name
    case self
    when Avail then "Tổng hợp"
    when Draft then "Tạm thời"
    when Chivi then "Chính thức"
    else            "Bên ngoài"
    end
  end

  def self.parse(sname : String)
    case sname
    when "~chivi" then Chivi
    when "~draft" then Draft
    when "~avail" then Avail
    else               Other
    end
  end
end
