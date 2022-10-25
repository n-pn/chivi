class MT::TxtSeg
  def scan_ordnum(index : Int32 = 0)
    idx, _tag, new_val = scan_hannum(index &+ 1)
    {idx, MtlTag::Ordinal, "thứ #{new_val}"}
  end
end
