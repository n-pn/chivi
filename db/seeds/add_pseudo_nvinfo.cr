data = [
  CV::Nvinfo.new({
    id:        0,
    author_id: 0,

    bhash: "tong-hop",
    bslug: "tong-hop",
    zname: "tong-hop",
    hname: "Tổng hợp",
    vname: "Tổng hợp",
    hslug: "",
    vslug: "",

    shield: 2,
  }),
  CV::Nvinfo.new({
    id:        -1,
    author_id: 0,

    bhash: "dai-sanh",
    bslug: "dai-sanh",
    zname: "dai-sanh",
    hname: "Đại sảnh",
    vname: "Đại sảnh",
    hslug: "",
    vslug: "",

    shield: 2,
  }),
  CV::Nvinfo.new({
    id:        -2,
    author_id: 0,

    bhash: "huong-dan",
    bslug: "huong-dan",
    zname: "huong-dan",
    hname: "Hướng dẫn",
    vname: "Hướng dẫn",
    hslug: "",
    vslug: "",

    shield: 2,
  }),
  CV::Nvinfo.new({
    id:        -3,
    author_id: 0,

    bhash: "thong-bao",
    bslug: "thong-bao",
    zname: "thong-bao",
    hname: "Thông báo",
    vname: "Thông báo",
    hslug: "",
    vslug: "",

    shield: 2,
  }),
]

CV::Author.new({
  id:     0,
  zname:  "system",
  vname:  "system",
  vslug:  "",
  weight: -1,
}).save

data.each do |book|
  book.save
rescue err
  puts err
end
