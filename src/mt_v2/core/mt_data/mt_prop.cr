@[Flags]
enum M2::MtProp
  Void # for word that marked empty

  NoSpaceL # no space before
  NoSpaceR # no space after

  CapRelay # relay capitalization
  CapAfter # add capitalizion after this node

  def self.parse(array : Array(String))
    array.reduce(None) { |memo, prop| memo | parse(attr) }
  end

  def self.init(apply_cap : Bool = true)
    apply_cap ? self.flags(CapAfter, NoSpaceR) : NoSpaceR
  end
end
