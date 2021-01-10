require "kemal"
require "kemal-session"

require "../_oldcv/engine"
require "../_oldcv/kernel"

module CV::Server::RouteUtils
  extend self

  def parse_page(page : String, limit = 24)
    page = page.to_i? || 1

    offset = (page - 1) * limit
    offset = 0 if offset < 0

    {limit, offset}
  end

  def search_type(type : String?)
    case type
    when "title"  then :title
    when "author" then :author
    else               :fuzzy
    end
  end

  def search_order(order : String?)
    case order
    when "weight", "tally" then :weight
    when "voters", "votes" then :voters
    when "rating", "score" then :rating
    when "access"          then :access
    when "update"          then :update
    else                        :access
    end
  end

  def search_page(page : String?)
    return 1 unless page = page.try(&.to_i?)
    page = 1 if page < 1
    page
  end

  def search_limit(limit : String?, upper = 24)
    return upper unless limit = limit.try(&.to_i?)
    limit < 1 || limit > upper ? upper : limit
  end

  def json_res(env, data, cached = 0)
    json_res(env, cached: cached) { |res| data.to_json(res) }
  end

  def json_res(env, cached = 0)
    if cached > 0
      env.response.headers.add("ETag", cached.to_s)
      env.response.headers.add("Cache-Control", "max-age=300")
    end

    env.response.content_type = "application/json"
    yield env.response
  end

  def books_json(io : IO, books : Array(Oldcv::BookInfo), total = books.size)
    JSON.build(io) do |json|
      json.object do
        json.field "_s", "ok"
        json.field "total", total

        json.field "books" do
          json.array do
            books.each do |book|
              json.object do
                json.field "ubid", book.ubid
                json.field "slug", book.slug
                json.field "vi_title", book.vi_title
                json.field "zh_title", book.zh_title
                json.field "vi_author", book.vi_author
                json.field "zh_author", book.zh_author
                json.field "vi_genres", book.vi_genres
                json.field "main_cover", book.main_cover
                json.field "rating", book.rating
                json.field "voters", book.voters
                json.field "mftime", book.mftime
              end
            end
          end
        end
      end
    end
  end
end
