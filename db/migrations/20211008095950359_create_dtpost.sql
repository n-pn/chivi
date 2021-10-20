-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE dtposts (
  id bigserial primary key,

  cvuser_id bigint not null default 0,
  dtopic_id bigint not null default 0,

  tagged_ids bigint[] not null default '{}', -- tagged cvuser ids
  
  dt_id int not null default '0', -- post index of a single topic

  input text not null default '', -- text input
  itype text not null default 'md', -- input type, default is markdown

  ohtml text not null default '', -- html output
  odesc text not null default '', -- short description

  state int not null default '0', -- states: public, deleted...
  utime bigint not null default '0', -- update time, change after edits
   
  likes int not null default '0', -- like count
  edits int not null default '0', -- edit count
  award int not null default '0', -- karma given by users to this post

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX dtpost_cvuser_idx ON dtposts (cvuser_id);
CREATE INDEX dtpost_dtopic_idx ON dtposts (dtopic_id, dt_id);
CREATE INDEX dtpost_tagged_idx ON dtposts using GIN (tagged_ids);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS dtposts;