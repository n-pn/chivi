-- +micrate Up
CREATE TABLE ubmarks (
  id bigserial primary key,

  cvbook_id bigint not null,
  cvuser_id bigint not null,

  bmark int not null default 0,
  zseed int not null default 0,

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX ubmark_unique_idx ON ubmarks (cvbook_id, cvuser_id);
CREATE INDEX ubmark_cvuser_idx ON ubmarks (cvuser_id, bmark);


-- +micrate Down
DROP TABLE IF EXISTS ubmarks;
