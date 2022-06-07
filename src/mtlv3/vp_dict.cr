require "../cvmtl/vp_dict"

module CV::MT2
  class VpDict < CV::VpDict
    getter term : POS::Phrase { POS.init(self) }
  end
end
