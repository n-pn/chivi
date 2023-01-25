require "../src/_data/wnovel/nv_info"

CV::Btitle.new({
  id:    0,
  zname: "Tổng hợp",
  hname: "Tổng hợp",
  vname: "Tổng hợp",
}).save!

CV::Nvinfo.new({
  id:        0,
  author_id: 0,
  btitle_id: 0,
  vname:     "Tổng hợp",
  bhash:     "combine",
  bslug:     "tong-hop",
  shield:    2,
}).save!
