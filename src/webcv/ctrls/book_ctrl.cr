require "./base_ctrl"

class CV::BookCtrl < CV::BaseCtrl
  def index
    matched = NvInfo.filter(params.to_h)
    response.headers.add("Cache-Control", "public, min-fresh=180")
    list_books(matched)
  end

  def user_books
    uname = params["uname"].downcase
    blist = params.fetch("bmark", "reading")
    matched = ViMark.all_books(uname, blist)
    list_books(matched)
  end

  def show
    bslug = params["bslug"]

    unless bhash = NvInfo.find_by_slug(bslug)
      return halt!(404, "Quyển sách không tồn tại!")
    end

    if cu_privi > 0
      access = Time.utc.to_unix // 60
      NvOrders.set_access!(bhash, access, force: true)
      spawn { NvOrders.access.save!(clean: false) }
    end

    response.headers.add("Cache-Control", "min-fresh=60")
    nvinfo = NvInfo.load(bhash)
    render_json(nvinfo)
  end

  private def list_books(matched : Set(String)?)
    skip = clamp(params.fetch_int(:skip), min: 0)
    take = clamp(params.fetch_int(:take), min: 1, max: 24)

    order = params.fetch(:order, "access")
    total = matched ? matched.size : NvOrders.get(order).size

    render_json do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "total", total

          json.field "books" do
            json.array do
              NvInfo.each(order, skip: skip, take: take + 1, matched: matched) do |bhash|
                NvInfo.load(bhash).to_json(json, full: false)
              end
            end
          end
        end
      end
    end
  end
end
