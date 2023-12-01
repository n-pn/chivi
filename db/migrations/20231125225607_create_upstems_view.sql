-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE OR REPLACE VIEW upstems_view AS
SELECT
  c.*,
  u.guard,
  u.wndic,
  u.vintro,
  u.labels
FROM
  upstems AS u
  INNER JOIN tsrepos AS c ON c.stype = 1
    AND c.sn_id = u.id;

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP VIEW upstems_view;
