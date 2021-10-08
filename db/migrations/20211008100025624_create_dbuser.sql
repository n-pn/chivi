-- +micrate Up
CREATE TABLE dbusers (
  id bigserial primary key,

  cvuser_id bigint not null,
  dboard_id bigint not null,

  trace int not null default 0, -- 0: nothing, 1: liked, 2: ignore...
  utime bigint not null default 0, -- update when trace changes
  atime bigint not null default 0, -- last time visit the board

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX dbuser_unique_idx ON dbusers (cvuser_id, dboard_id);
CREATE INDEX dbuser_traces_idx ON dbusers (dboard_id, trace);

-- +micrate Down
DROP TABLE IF EXISTS dbusers;
