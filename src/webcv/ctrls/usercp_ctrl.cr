require "./base_ctrl"

class CV::UsercpCtrl < CV::BaseCtrl
  def replied
    limit, offset = params.get_paged(min: 10)

    query = Dtpost.query
      .where("state >= 0")
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
end
