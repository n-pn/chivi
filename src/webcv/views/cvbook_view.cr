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
end
