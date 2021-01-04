require "./shared/*"
require "./engine/*"
require "./filedb/*"

module CV::Kernel
  extend self

  def load_info(bhash : String)
    {
      bhash: bhash,
      bslug: Nvinfo._index.fval(bhash),

      btitle: Nvinfo.btitle.get(bhash),
      author: Nvinfo.author.get(bhash),
      genres: Nvinfo.genres.get(bhash),
    }
  end
end
