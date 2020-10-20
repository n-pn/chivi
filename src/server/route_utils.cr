require "kemal"
require "kemal-session"

require "../libcv"
require "../kernel"

module Server::Utils
  extend self

  def parse_page(input : String, limit = 20)
    page = input.to_i? || 1

    offset = (page - 1) * limit
    offset = 0 if offset < 0

    {limit, offset}
  end

  def json_error(message : String)
    {_stt: "err", _msg: message}.to_json
  end

  def return_user(env, user : UserInfo)
    env.session.string("uslug", user.uslug)
    {_stt: "ok", uname: user.uname, power: user.power}.to_json(env.response)
  end

  def books_json(io : IO, books : Array(BookInfo), total = books.size)
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
