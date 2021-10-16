require "./base_ctrl"

class CV::TlspecCtrl < CV::BaseCtrl
  def index
    pgidx = params.fetch_int("page", min: 1)
    limit = 24
    start = (pgidx - 1) * limit
    total = Tlspec.items.size

    json_view do |jb|
      jb.object {
        jb.field "total", total
        jb.field "pgidx", pgidx
        jb.field "pgmax", (total - 1) // limit + 1

        jb.field "items" {
          jb.array {
            Tlspec.items[start..(start + limit)].each do |ukey|
              entry = Tlspec.load!(ukey)
              next unless entry.utime

              jb.object {
                jb.field "ztext", entry.ztext
                jb.field "utime", entry.utime

                jb.field "uname", entry.uname
                jb.field "unote", entry.unote

                jb.field "status", entry.status
                jb.field "labels", entry.labels
              }
            end
          }
        }
      }
    end
  end

  private def extract_ztext
    ztext = params["ztext"]?
    return halt! 400, "Câu văn gốc không được để trắng!" unless ztext
    return halt! 403, "Câu văn gốc quá dài, mời nhập lại" if ztext.size > 200
    ztext
  end

  private def extract_unote
    unote = params["unote"]?
    return "" unless unote
    return halt! 403, "Câu văn gốc quá dài, mời nhập lại" if unote.size > 500
    unote.gsub("\n", "   ")
  end

  def create
    return halt! 403, "Quyền hạn của bạn không đủ, mời thử lại sau." if cu_privi < 0
    return unless ztext = extract_ztext
    return unless unote = extract_unote

    entry = Tlspec.init!
    entry.push ["ztext", ztext]

    ctime = Time.utc.to_unix.to_s
    dname = params["dname"]? || "combine"
    slink = params["slink"]? || "."
    entry.push ["_orig", ctime, dname, slink]

    entry.push ["_note", _cv_user.uname, unote]
    entry.save!

    json_view(["ok"])
  rescue err
    Log.error { err.message.colorize.red }
    halt! 500, "Có lỗi từ hệ thống, mời check lại!"
  end

  @entry : Tlspec? = nil

  before_action do
    only [:show, :update, :delete] do
      entry = Tlspec.load!(params["ukey"])
      next halt!(404, "Không có dữ liệu") unless entry.utime
      @entry = entry
    end
  end

  def show
    return unless entry = @entry

    json_view do |jb|
      jb.object {
        jb.field "ztext", entry.ztext
        jb.field "dname", entry.dname
        jb.field "slink", entry.slink

        jb.field "ctime", entry.ctime
        jb.field "utime", entry.utime

        jb.field "uname", entry.uname
        jb.field "unote", entry.unote

        jb.field "status", entry.status
        jb.field "labels", entry.labels

        jb.field "_logs", entry._logs
      }
    end
  end

  def update
  end

  def delete
  end
end
