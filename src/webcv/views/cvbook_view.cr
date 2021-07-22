require "json"

module CV::Views::CvbookView
  extend self

  def render(jb : JSON::Builder, obj : NvInfo, full = true)
    jb.object do
      jb.field "bhash", obj.bhash
      jb.field "bslug", obj.bslug

      jb.field "btitle_zh", obj.btitle[0]
      jb.field "btitle_hv", obj.btitle[1]
      jb.field "btitle_vi", obj.btitle[2]

      jb.field "author_zh", obj.author[0]
      jb.field "author_vi", obj.author[1]

      jb.field "genres", obj.genres
      jb.field "bcover", obj.bcover

      jb.field "voters", obj.voters
      jb.field "rating", obj.rating

      if full
        jb.field "bintro", obj.bintro

        jb.field "update", obj.update
        jb.field "status", obj.status

        jb.field "yousuu", obj.yousuu
        jb.field "origin", obj.origin

        jb.field "snames", obj.snames
        jb.field "chseed" do
          jb.object do
            obj.snames.each do |sname|
              jb.field sname, obj.get_chseed(sname)
            end
          end
        end
      end
    end
  end

  def render(jb : JSON::Builder, obj : Cvbook, full = true)
    jb.object do
      jb.field "bhash", obj.bhash
      jb.field "bslug", obj.bslug

      jb.field "btitle_zh", obj.ztitle
      jb.field "btitle_hv", obj.htitle
      jb.field "btitle_vi", obj.vtitle.empty? ? obj.htitle : obj.vtitle

      jb.field "author_zh", obj.author.zname
      jb.field "author_vi", obj.author.vname

      jb.field "genres", obj.bgenres
      jb.field "bcover", obj.bcover

      jb.field "voters", obj.voters
      jb.field "rating", obj.rating / 10.0

      if full
        jb.field "bintro", obj.bintro.split("\n")

        jb.field "update", obj.update
        jb.field "status", obj.status

        if ysbook = obj.ysbooks[0]?
          jb.field "yousuu", ysbook.id
          jb.field "origin", ysbook.root_link
        end

        jb.field "snames", obj.zhseeds
        jb.field "chseed" do
          jb.object do
            obj.zhbooks.each do |zhbook|
              jb.field zhbook.sname, zhbook.snvid
            end
          end

          jb.field "chivi", obj.bhash
        end
      end
    end
  end
end
