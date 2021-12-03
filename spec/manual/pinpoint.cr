require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "这两件衣服一大一小，大的那个是男款，女款则是很小的童装，毫无疑问，这正是一周前罗亚亲自去索罗菲亚商会订下的衣服。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res
