-- +micrate Up
CREATE TABLE vicrits (
  id serial primary key,

  viuser_id int not null references viusers(id) on update cascade on delete cascade,
  nvinfo_id bigint not null references viusers(id) on update cascade on delete cascade,

  vilist_id int not null,
  unique(nvinfo_id, vilist_id),

  stars int not null default 3,

  itext text not null,
  ohtml text not null default '',

  btags varchar[] not null default '{}',

  _flag int not null default 0,
  _sort int not null default 0,

  like_count int not null default 0,
  repl_count int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP,
  changed_at timestamptz
);

CREATE INDEX vicrit_viuser_idx ON vicrits (viuser_id);
CREATE INDEX vicrit_vilist_idx ON vicrits (vilist_id);

CREATE INDEX vicrit_stars_idx ON vicrits (stars);
CREATE INDEX vicrit_sorts_idx ON vicrits (_sort);
CREATE INDEX vicrit_likes_idx ON vicrits (like_count);

CREATE INDEX vicrit_btags_idx ON vicrits using GIN (btags);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS vicrits;
