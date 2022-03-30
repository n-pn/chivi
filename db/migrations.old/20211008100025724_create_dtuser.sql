-- +micrate Up
CREATE TABLE dtusers (
  id bigserial primary key,

  cvuser_id bigint not null,
  dtopic_id bigint not null,

  trace int not null default 0, -- 0: nothing, 1: liked, 2: creator...
  utime bigint not null default 0, -- update when trace changes
  
  atime bigint not null default 0, -- last time visit the thread
  reads int not null default 0, -- posts readed

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX dtuser_unique_idx ON dtusers (cvuser_id, dtopic_id);
CREATE INDEX dtuser_traces_idx ON dtusers (dtopic_id, trace);

-- +micrate Down
DROP TABLE IF EXISTS dtusers;
