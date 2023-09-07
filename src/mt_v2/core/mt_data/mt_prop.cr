@[Flags]
enum M2::MtAttr
  Void # for word that marked empty

  NoSpaceL # no space before
  NoSpaceR # no space after

  CapRelay # relay capitalization
  CapAfter # add capitalizion after this node

  HUMAN # person name
  SPACE # location or organization

  HSUFF # person honorific
  SSUFF # location/organization indication suffixes

  XFLIP # mark no flip

  IP_NO_OBJ # sentence missing object

  TIME   # mark noun phrase, prepos phrase
  REASON # mark prepos phrase
  MANNER # mark prepos phrase

  NO_VCD # can't make cooridnated verb compounds
  NO_VRD # can't make verb-resultative and verb-directional compounds

  def self.parse(array : Array(String))
    array.reduce(None) { |memo, prop| memo | parse(prop) }
  end

  def self.init(apply_cap : Bool = true)
    apply_cap ? self.flags(CapAfter, NoSpaceR) : NoSpaceR
  end
end
