-- +micrate Up
CREATE TABLE yslists (
  id bigserial primary key,
  origin_id text not null,

  ysuser_id bigint not null default 0,

  zname text not null,
  vname text not null,

  zdesc text not null default '',
  vdesc text not null default '',

  vslug text not null default '-',
  klass text not null default 'male',

  covers text[] not null default '{}';
  genres text[] not null default '{}';

  utime bigint not null default 0,
  stime bigint not null default 0,

  _bump int not null default 0,
  _sort int not null default 0,

  book_count int not null default 0,
  book_total int not null default 0,

  like_count int not null default 0,
  view_count int not null default 0,
  star_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX yslist_origin_idx ON yslists (origin_id);

CREATE INDEX yslist_ysuser_idx ON yslists (ysuser_id);
CREATE INDEX yslist_search_idx ON yslists using GIN (vslug gin_trgm_ops);

CREATE INDEX yslist_update_idx ON yslists (utime);
CREATE INDEX yslist_viewed_idx ON yslists (view_count);
CREATE INDEX yslist_ranked_idx ON yslists (like_count);


-- +micrate Down
DROP TABLE IF EXISTS yslists;
