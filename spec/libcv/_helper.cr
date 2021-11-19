require "spec"
require "../../src/cvmtl/mt_core"

MTL = CV::MtCore.generic_mtl("combine")

def convert(input : String)
  MTL.cv_plain(input, cap_first: false).to_s
end

macro assert_eq(left, right)
  convert({{left}}).should eq({{right}})
end
