-- +micrate Up
CREATE TABLE vilists (
  id serial primary key,
  viuser_id int not null references viusers(id) on update cascade on delete cascade,

  title text not null,
  tslug text not null default '',

  dtext text not null, -- description input
  dhtml text not null default '', -- description html

  klass varchar not null default 'male',

  covers varchar[] not null default '{}',
  genres varchar[] not null default '{}',

  _flag int not null default 0,
  _sort int not null default 0,
  _bump int not null default 0,

  book_count int not null default 0,
  like_count int not null default 0,
  star_count int not null default 0,
  view_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);


CREATE INDEX vilist_viuser_idx ON vilists (viuser_id);
CREATE INDEX vilist_search_idx ON vilists using GIN (tslug gin_trgm_ops);

CREATE INDEX vilist_sorts_idx ON vilists (_sort);
CREATE INDEX vilist_bumps_idx ON vilists (_bump);

CREATE INDEX vilist_stars_idx ON vilists (star_count);
CREATE INDEX vilist_likes_idx ON vilists (like_count);
CREATE INDEX vilist_views_idx ON vilists (view_count);


-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS vilist;
