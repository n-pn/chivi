require "spec"
require "../../src/libcv/mt_core"

MTL = CV::MtCore.generic_mtl("combine")

def convert(input : String)
  MTL.cv_plain(input, cap_first: false).to_s
end

macro assert_eq(left, right)
  convert({{left}}).should eq({{right}})
end
