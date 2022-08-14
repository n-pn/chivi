require "spec"
require "../../../src/mtlv2/engine/mt_node/*"

module MtlV2::MTL
  extend self

  def parse_attr(str : String)
    PunctAttr.from_str(str)
  end

  describe PunctAttr do
    it "properly mapping punctuation attributes" do
      parse_attr(".").should eq PunctAttr.flags(Period, Final, Break, CapAfter, NoWspace)

      # parse_attr(" ").includes?(PunctAttr.flags(Wspace, Start)).should eq true
      # parse_attr(",").includes?(PunctAttr.flags(Wspace, Start)).should eq false
      # parse_attr("“").includes?(PunctAttr.flags(Wspace, Start)).should eq true
    end
  end
end
