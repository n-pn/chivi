struct CV::PosTag
  def self.map_verb(tag : String, key : String)
    case tag[1]?
    when 'n' then Veno
    when 'd' then Vead
    when 'f' then Vdir
    when 'c' then Vcmp
    when 'i' then Vint
    when 'j' then Vinx
    when '2' then Vtwo
    when 'o' then Vobj
    when 'm', 'x'
      parse_vmodal(key)
    else Verb
    end
  end
end
