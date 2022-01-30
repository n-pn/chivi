require "./base_ctrl"

class CV::UsercpCtrl < CV::BaseCtrl
  def replied
    limit, offset = params.get_paged(min: 10)

    query = Dtpost.query
      .where("state >= 0 AND cvuser_id != ?", _cvuser.id)
      .where("(repl_cvuser_id = ? OR tagged_ids @> ?::bigint[])", _cvuser.id, [_cvuser.id])
      .order_by(id: :desc)
      .with_dtopic.with_cvuser
      .limit(limit).offset(offset)

    cache_rule :private, 10, 60
    json_view(query.map { |x| DtpostView.new(x, full: true) })
  rescue err
    Log.error { err }
    halt!(500, err.message)
  end

  def upgrade
    privi = params.fetch_int("privi", min: 1, max: 3)
    tspan = params.fetch_int("tspan", min: 1, max: 4)

    json_view(_cvuser.upgrade!(privi, tspan))
  rescue err
    halt! 400, "Bạn chưa đủ số vcoid tối thiểu để tăng quyền hạn!"
  end
end
