-- +micrate Up
CREATE TABLE dpusers (
  id bigserial primary key,

  cvuser_id bigint not null,
  dtpost_id bigint not null,

  trace int not null default 0, -- 0: nothing, 1: liked, 2: creator...
  utime bigint not null default 0, -- update when trace changes
  award int not null default '0', -- karma given by user to the post

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX dpuser_unique_idx ON dpusers (cvuser_id, dtpost_id);
CREATE INDEX dpuser_traces_idx ON dpusers (dtpost_id, trace);

-- +micrate Down
DROP TABLE IF EXISTS dpusers;
