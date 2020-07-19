require "./_utils"
require "../kernel"

module Server
  get "/_list_book" do |env|
    word = env.params.query.fetch("word", "")

    type =
      case env.params.query.fetch("type", "")
      when "title"  then :title
      when "author" then :author
      else               :fuzzy
      end

    genre = env.params.query.fetch("genre", "")

    order =
      case env.params.query.fetch("sort", "access")
      when "weight", "tally" then :weight
      when "rating", "score" then :rating
      when "access"          then :access
      when "update"          then :update
      else                        :weight
      end

    page = env.params.query.fetch("page", "1")
    limit, offset = Utils.parse_page(page, 20)

    anchor = env.params.query.fetch("anchor", "")

    opts = BookRepo::Query::Opts.new(word, type, genre, order, limit, offset, anchor)

    infos, total = BookRepo::Query.fetch!(opts)

    items = infos.map do |info|
      {
        ubid:      info.ubid,
        slug:      info.slug,
        vi_title:  info.vi_title,
        vi_author: info.vi_author,
        vi_genres: info.vi_genres,
        rating:    info.rating,
        voters:    info.voters,
      }
    end

    {items: items, total: total, query: opts}.to_json(env.response)
  end

  get "/_load_book" do |env|
    slug = env.params.query["slug"]

    unless info = BookRepo.find(slug)
      halt env, status_code: 404, response: Utils.json_error("Book not found!")
    end

    BookRepo.inc_counter(info, read: false)
    {book: info}.to_json(env.response)
  end

  get "/_get_chaps" do |env|
    slug = env.params.query["slug"]
    seed = env.params.query["seed"]
    reload = env.params.query.fetch("reload", "false") == "true"

    unless info = BookRepo.find(slug)
      halt env, status_code: 404, response: Utils.json_error("Book not found!")
    end

    unless fetched = Kernel.load_list(info, seed, reload: reload)
      halt env, status_code: 404, response: Utils.json_error("Seed not found!")
    end

    BookRepo.bump_access(info)
    BookRepo.inc_counter(info, read: false)

    chlist, mftime = fetched
    chlist = chlist.chaps.map do |chap|
      {
        scid:  chap.scid,
        slug:  chap.url_slug,
        label: chap.vi_label,
        title: chap.vi_title,
      }
    end

    {chlist: chlist, mftime: mftime}.to_json(env.response)
  end

  get "/_load_text" do |env|
    slug = env.params.query["slug"]

    unless info = BookRepo.find(slug)
      halt env, status_code: 404, response: Utils.json_error("Book not found!")
    end

    BookRepo.bump_access(info)
    BookRepo.inc_counter(info, read: true)

    seed = env.params.query["seed"]
    unless fetched = Kernel.load_list(info, seed, reload: false)
      halt env, status_code: 404, response: Utils.json_error("Seed not found!")
    end

    scid = env.params.query["scid"]
    list, _ = fetched

    unless index = list.index[scid]?
      halt env, status_code: 404, response: Utils.json_error("Chapter not found!")
    end

    curr_chap = list.chaps[index]
    prev_chap = list.chaps[index - 1] if index > 0
    next_chap = list.chaps[index + 1] if index < list.size - 1

    mode = env.params.query.fetch("mode", "0").try(&.to_i) || 0

    {
      book_ubid: info.ubid,
      book_slug: info.slug,
      book_name: info.vi_title,
      seed_name: seed,
      ch_index:  index + 1,
      ch_total:  list.size,

      prev_url: prev_chap.try(&.slug_for(seed)),
      next_url: next_chap.try(&.slug_for(seed)),
      curr_url: curr_chap.try(&.slug_for(seed)),

      # content: ChapText.load_vp(site, bsid, scid, user, info.ubid, mode: mode),
    }.to_json(env.response)
  end
end
