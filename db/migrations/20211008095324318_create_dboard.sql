-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE dboards (
  id bigserial primary key, -- match with cvbook id

  bname text not null, -- board name
  bslug text unique not null, -- board unique slug

  btype int not null default '0', -- types of board: book or generic
  bdesc text not null default '', -- board caption

  topics int not null default '0', -- topic count
  tposts int not null default '0', -- tpost count

  likes int not null default '0',
  views int not null default '0',

  utime bigint not null default '0',
  atime bigint not null default '0',

  _sort int not null default '0', 

  created_at timestamptz not null default CURRENT_TIMESTAMP,
  updated_at timestamptz not null default CURRENT_TIMESTAMP
);

CREATE INDEX dboard_bslug_idx ON dboards using GIN (bslug gin_trgm_ops);
CREATE INDEX dboard_sorts_idx ON dboards (_sort);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS dboards;