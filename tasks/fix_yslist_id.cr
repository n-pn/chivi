require "./shared/bootstrap"

CV::Yslist.query.each do |yslist|
  old_id = yslist.id
  new_id = CV::Yslist.gen_id(yslist.origin_id)

  Clear::SQL.transaction do
    Clear::SQL.execute <<-SQL
      UPDATE yslists set id = #{new_id} where id = #{old_id};
      UPDATE yscrits set yslist_id = #{new_id} WHERE yslist_id = #{old_id};
    SQL
  end
end
