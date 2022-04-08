require "./nvinfo_data"

class CV::NvseedData < CV::NvinfoData
  def add!(entry, snvid : String, stime : Int64)
    super
    status.append(snvid, Status.new(entry.status_int, entry.status_str))
  end

  def seed!(sname : String, force : Bool = false, index : Int32 = 1)
    super(force: force)
    NvinfoData.print_stats(sname, index: index)
  end

  def seed_entry!(snvid : String, bindex : Bindex, force : Bool = false)
    puts "TODO!"
  end
end
