module CV::ACL
  extend self

  def upsert_chtext(sname : String, uname : String = "")
    case sname[0]?
    when '@' then sname == "@" + uname ? 1_i8 : 4_i8
    when '=' then 2_i8
    else          3_i8
    end
  end
end
