-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE wnlinks (
  id serial primary key,
  book_id int4 not null references nvinfos(id) on update cascade on delete cascade,

  link text not null,
  name text not null,
  type int4 not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

create index wnlink_name_idx on wnlinks(type, link);
create unique index wnlink_book_idx on wnlinks(book_id, link);

insert into wnlinks(book_id, link, name, type)
select distinct nvinfo_id::int, pub_link, pub_name, 1 from ysbooks
order by nvinfo_id asc;

insert into wnlinks(book_id, link, name, type)
select nvinfo_id::int, 'https://www.yousuu.com/book/' || id::text, 'yousuu', 2 from ysbooks
order by nvinfo_id asc;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

drop table wnlinks;
