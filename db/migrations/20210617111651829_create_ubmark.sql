-- +micrate Up
CREATE TABLE ubmarks (
  id bigserial PRIMARY KEY,

  cvbook_id bigint not null,
  cvuser_id bigint not null,

  bmark int default 0 not null,
  zseed int default 0 not null,

  created_at timestamptz default CURRENT_TIMESTAMP NOT NULL,
  updated_at timestamptz default CURRENT_TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX ubmark_unique_idx ON ubmarks (cvbook_id, cvuser_id);
CREATE INDEX ubmark_cvuser_idx ON ubmarks (cvuser_id, bmark);


-- +micrate Down
DROP TABLE IF EXISTS ubmarks;
