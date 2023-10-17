-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied

create view vicrits_view as
select
  t.id as vc_id,

  t.viuser_id as vu_id,
  t.nvinfo_id::int as wn_id,
  t.vilist_id as vl_id,

  t.stars as stars,
  t.ohtml as ohtml,
  t.btags as btags,
  t._sort as _sort,

  extract(epoch from t.created_at)::bigint as ctime,
  extract(epoch from coalesce(t.changed_at, t.created_at))::bigint as utime,

  t.like_count,
  t.repl_count,

  u.uname as u_uname,
  u.privi as u_privi,

  (b.id || '-' || b.bslug) as b_uslug,
  b.btitle_vi as b_title,

  l.title as l_title,
  (l.id || '-' ||  l.tslug) as l_uslug,
  l.book_count as l_count

  from vicrits as t
  inner join viusers as u
    on u.id = t.viuser_id
  inner join wninfos as b
    on b.id = t.nvinfo_id
  inner join vilists as l
    on l.id = t.vilist_id

  where t.id > 0;


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
drop view vicrits_view;
