-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE dtopics ( 
  id bigserial primary key,

  cvuser_id bigint not null default 0,
  dboard_id bigint not null default 0,
  label_ids int[] not null default '{}',

  title text not null default '',
  uslug text not null default '',

  state int not null default '0', -- states: public, sticky, deleted....
  utime bigint not null default '0', -- update when new post created
  _sort int not null default '0',-- natural sort order, generate by utime, likes...

  posts int not null default '0', -- post count
  marks int not null default '0', -- like count
  views int not null default '0', -- view count

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP 
);


CREATE INDEX dtopic_cvuser_idx ON dtopics (cvuser_id);
CREATE INDEX dtopic_dboard_idx ON dtopics (dboard_id, _sort);
CREATE INDEX dtopic_labels_idx ON dtopics using GIN (label_ids);
CREATE INDEX dtopic_uslug_idx ON dtopics using GIN (uslug gin_trgm_ops);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back

DROP TABLE IF EXISTS dtopics;
