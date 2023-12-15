require "../data/tsrepo"

class RD::TsrepoView
  def self.for_wn(wn_id : Int32)
    query = Tsrepo.schema.select_stmt do |sql|
      sql << " where wn_id = $1"
      sql << " order by stype asc, mtime desc"
    end

    PGDB.query_all(query, wn_id, as: Tsrepo)
  end
end
