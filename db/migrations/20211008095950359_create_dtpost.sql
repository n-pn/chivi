-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE dtposts (
  id bigserial primary key,

  cvuser_id bigint not null default 0,
  dtopic_id bigint not null default 0,

  tagged_ids bigint[] not null default '{}', -- tagged cvuser ids
  
  index int not null default '0'; 

  input text not null default '', -- text input
  itype text not null default 'md', -- input type, default is markdown

  ohtml text not null default '', -- html output
  state int not null default '0'; -- states: public, deleted...
   
  likes int not null default '0', -- like count
  edits int not null default '0', -- edit count

  utime bigint not null default '0', -- update time, change after edits

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX dtpost_cvuser_idx ON tdposts (cvuser_id);
CREATE INDEX dtpost_dtopic_idx ON tdposts (dtopic_id, index);
CREATE INDEX dtpost_tagged_idx ON tdposts using GIN (tagged_ids);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS tdposts;