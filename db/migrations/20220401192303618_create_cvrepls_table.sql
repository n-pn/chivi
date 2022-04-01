-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE cvrepls (
  id bigserial primary key,
  ii int not null default 0, -- post index of a single topic

  cvuser_id bigint not null default 0,
  cvpost_id bigint not null default 0,

  tagged_ids bigint[] not null default '{}', -- tagged cvuser ids

  repl_cvrepl_id bigint not null default '0',
  repl_cvuser_id bigint not null default '0',

  input text not null default '', -- text input
  itype text not null default 'md', -- input type, default is markdown

  ohtml text not null default '', -- html output
  otext text not null default '', -- text output

  state int not null default 0, -- states: public, deleted...
  utime bigint not null default 0, -- update time, change after edits

  edit_count int not null default 0, -- edit count
  like_count int not null default 0, -- like count
  repl_count int not null default 0, -- like count

  coins int not null default 0, -- karma given by users to this post

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX cvrepl_cvuser_idx ON cvrepls (cvuser_id);
CREATE INDEX cvrepl_cvpost_idx ON cvrepls (cvpost_id, ii);
CREATE INDEX cvrepl_tagged_idx ON cvrepls using GIN (tagged_ids);

CREATE INDEX cvrepl_repl_cvrepl_idx ON cvrepls (repl_cvrepl_id);
CREATE INDEX cvrepl_repl_cvuser_idx ON cvrepls (repl_cvuser_id);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS cvrepls;
