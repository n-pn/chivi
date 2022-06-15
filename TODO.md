# TODO

## Doing

- cleanup chtext() functionality:
  allow multi pass lookup

- fix nvseed update action:

  - add `last_sname` to nvseed table
  - check for mirror seed base on latest chapter

- manual import mirrors

- improve `=base` seed auto generation
  - ...

## Pending

- allow `theme` dicts
- improve terms managements
- add discussion base on term

- split `users` nvseed to users's own custom nvseed record

## Onhold

- import common terms ( words analyzed by LAC that exists in at least 50 books or in dictionaries)
  - for current existing terms: update postag from baidu/lac result
  - extract common terms definition from external vietphrase dicts
    - cleanup misspelling and other trashes
  - generate definitions for missing terms

## Future

- create flatfile store for nvseed raw data like zh_btitle, zh_author, zh_descs, zh_genres, cover_url....
