-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE cvposts (
  id bigserial primary key,
  ii int8 not null default 1,

  viuser_id int4 not null default 0,
  nvinfo_id int8 not null default 0,

  lastrp_id int8 not null default 0,

  ptype int4 not null default 0,
  stars int4 not null default 3,

  labels text[] not null default '{}',
  lslugs text[] not null default '{}',

  title text not null default '',
  tslug text not null default '',
  brief text not null default '',

  state int4 not null default 0, -- states: public, sticky, deleted....
  utime int8 not null default 0, -- update when new post created

  _sort int4 not null default 0,
  _bump int4 not null default 0,

  repl_count int4 not null default 0, -- post count
  like_count int4 not null default 0, -- like count
  view_count int4 not null default 0, -- view count

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);


CREATE INDEX cvpost_cvuser_idx ON cvposts (viuser_id);
CREATE INDEX cvpost_nvinfo_idx ON cvposts (nvinfo_id);

CREATE INDEX cvpost_stars_idx ON cvposts (stars);
CREATE INDEX cvpost_sorts_idx ON cvposts (_sort);
CREATE INDEX cvpost_number_idx ON cvposts (ii);

CREATE INDEX cvpost_label_idx ON cvposts using GIN (lslugs);
CREATE INDEX cvpost_uslug_idx ON cvposts using GIN (tslug gin_trgm_ops);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS cvposts;
