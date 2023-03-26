-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE virepls (
  id serial primary key,

  viuser_id int not null references viusers(id) on update cascade on delete cascade,
  vicrit_id int not null references vicrits(id) on update cascade on delete cascade,

  itext text not null default '', -- text input
  ohtml text not null default '', -- html output

  _flag int not null default 0, -- states: public, deleted...
  _sort int not null default 0,

  like_count int not null default 0, -- like count

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP,
  changed_at timestamptz
);

CREATE INDEX virepl_cvuser_idx ON virepls (viuser_id);
CREATE INDEX virepl_vicrit_idx ON virepls (vicrit_id, _sort);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS virepls;
