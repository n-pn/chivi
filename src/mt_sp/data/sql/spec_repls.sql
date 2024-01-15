CREATE TABLE repls(
  id integer PRIMARY KEY,
  spec_id integer NOT NULL,
  post_no integer NOT NULL DEFAULT 0,
  btext text NOT NULL,
  bhtml text DEFAULT '',
  uname varchar NOT NULL DEFAULT '',
  mtime integer NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX repls_uniq_idx ON repls(spec_id, post_no);

CREATE INDEX repls_user_idex ON repls(uname);
