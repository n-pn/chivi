
-- delete from terms where id <> (
--   select max(id) from terms b
--   where b.dict_id = terms.dict_id
--   and b.mtime < (terms.mtime + 30)
--   and b.key = terms.key
-- );

-- delete from terms where key like '/%' and mtime = 0;
-- select count(*) from terms;

select id, key from terms a
  where a.dict_id in (
    select id from dicts where dtype = 30
  )
  and mtime < (
    select max(b.mtime) from terms b
    where b.dict_id = a.dict_id
    and b.key = a.key
  )
;
