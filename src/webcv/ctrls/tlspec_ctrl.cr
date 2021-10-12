require "./base_ctrl"

class CV::TlSpecCtrl < CV::BaseCtrl
  def index
    pgidx = params.fetch_int("page", min: 1)
    limit = 24
    start = (pgidx - 1) * limix
    total = Tspec.items.size

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
                jb.field "zhtxt", entry.zhtxt
                jb.field "utime", entry.utime

                jb.field "uname", entry.uname
                jb.field "tspec", entry.tspec

                jb.field "status", entry.status
                jb.field "labels", entry.labels
              }
            end
          }
        }
      }
    end
  end

  def show
    entry = Tlspec.load!(ukey)
    return halt!(404, "Không có dữ liệu") unless entry.utime
    json_view do |jb|
      jb.object {
        jb.field "zhtxt", entry.zhtxt
        jb.field "dname", entry.dname
        jb.field "slink", entry.slink

        jb.field "ctime", entry.ctime
        jb.field "utime", entry.utime

        jb.field "uname", entry.uname
        jb.field "tspec", entry.tspec

        jb.field "status", entry.status
        jb.field "labels", entry.labels

        jb.field "logs", entry.logs
      }
    end
  end

  private def convert(lines : Array(String), output : IO)
    dname = params.fetch_str("dname", "combine")
    cvmtl = MtCore.generic_mtl(dname, _cv_user.uname)

    lines.each_with_index do |line, idx|
      output << "\n" if idx > 0
      cvmtl.cv_plain(line, mode: 1).to_str(output)
    end
  end
end
