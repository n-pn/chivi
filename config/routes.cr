routes :api, "/api" do
  get "/books", CV::NvinfoCtrl, :index
  post "/books", CV::NvinfoCtrl, :upsert
  get "/books/:bslug/+edit", CV::NvinfoCtrl, :edit

  get "/books/:bslug", CV::NvinfoCtrl, :show
  get "/books/:bslug/front", CV::NvinfoCtrl, :front
  delete "/books/:bslug", CV::NvinfoCtrl, :delete

  # nvseed actions

  get "/seeds/:nv_id", CV::ChrootCtrl, :index
  put "/seeds/:nv_id/", CV::ChrootCtrl, :create
  get "/seeds/:nv_id/:sname", CV::ChrootCtrl, :show
  get "/seeds/:nv_id/:sname/:page", CV::ChrootCtrl, :chaps
  put "/seeds/:nv_id/:sname/patch", CV::ChrootCtrl, :patch
  put "/seeds/:nv_id/:sname/trunc", CV::ChrootCtrl, :trunc
  delete "/seeds/:nv_id/:sname", CV::ChrootCtrl, :prune

  # nvchap actions

  get "/chaps/:nv_id/:sname/:chidx/:cpart", CV::ChinfoCtrl, :ch_info
  get "/texts/:nv_id/:sname/:chidx", CV::ChtextCtrl, :rawtxt

  put "/texts/:nv_id/:sname", CV::ChtextCtrl, :upsert
  put "/texts/:nv_id/:sname/:chidx", CV::ChtextCtrl, :update
  patch "/texts/:nv_id/:sname/:chidx", CV::ChtextCtrl, :change

  get "/trans/:nv_id/:sname/:chidx/:part_no/:line_no", CV::ChtranCtrl, :list
  post "/trans/:nv_id/:sname/:chidx", CV::ChtranCtrl, :create

  # # dicts

  get "/dicts", CV::VpdictCtrl, :index
  get "/dicts/:dname", CV::VpdictCtrl, :show

  post "/terms/query", CV::VptermCtrl, :lookup
  put "/terms/entry", CV::VptermCtrl, :upsert_entry
  post "/terms/batch", CV::VptermCtrl, :upsert_batch

  # # quick trans

  # put "/qtran/hanviet", CV::QtransCtrl, :hanviet
  put "/qtran/mterror", CV::QtransCtrl, :mterror
  post "/qtran", CV::QtransCtrl, :webpage # to make the extension works
  put "/qtran", CV::QtransCtrl, :webpage  # to make the extension works
  get "/qtran/:type/:name", CV::QtransCtrl, :convert
  post "/qtran/posts", CV::QtransCtrl, :posts_upsert

  get "/tposts", CV::CvreplCtrl, :index
  post "/tposts", CV::CvreplCtrl, :create
  get "/tposts/:cvrepl/detail", CV::CvreplCtrl, :detail
  post "/tposts/:cvrepl", CV::CvreplCtrl, :update
  delete "/tposts/:cvrepl", CV::CvreplCtrl, :delete

  # # report

  get "/tlspecs/", CV::TlspecCtrl, :index
  get "/tlspecs/:ukey", CV::TlspecCtrl, :show
  post "/tlspecs", CV::TlspecCtrl, :create
  post "/tlspecs/:ukey", CV::TlspecCtrl, :update
  delete "/tlspecs/:ukey", CV::TlspecCtrl, :delete
end
