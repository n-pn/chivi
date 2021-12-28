require "./shared/bootstrap"

CV::Zhbook.query.where({zseed: 0}).each_with_cursor(20) do |zhbook|
  zhbook.sname = "users"
  zhbook.zseed = 99
  zhbook.save!

  zhbook.nvinfo.update({
    zseed_ids: zhbook.nvinfo.zseed_ids.reject(&.== 0).push(99),
  })
end

CV::Ubmemo.query.where({sname: "chivi"}).each_with_cursor(20) do |ubmemo|
  ubmemo.lr_sname = "users"
  ubmemo.lr_zseed = 99
  ubmemo.save!
end
