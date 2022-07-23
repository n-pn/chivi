class CV::NvrankCtrl < CV::BaseCtrl
  def brief
    book_query = Nvinfo.query.where("shield < 2").limit(6).offset(0)

    crit_query = Yscrit.query.order_by(id: :desc).limit(2).offset(0)
    list_query = Yslist.query.where("book_count > 0").order_by(utime: :desc).limit(2).offset(0)
    serv_json({
      recent: NvinfoView.map(book_query.dup.sort_by("access")),
      update: NvinfoView.map(book_query.dup.sort_by("update")),
      weight: NvinfoView.map(book_query.dup.sort_by("weight")),

      ycrits: YscritView.map(crit_query),
      ylists: YslistView.map(list_query),
    })
  end
end
