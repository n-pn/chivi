# TODO

## Current

### Fix hanviet

prepare:

- [ ] make `hanviet` dictionary access/editable by moderators
- [ ] extract list of most 20k popular book titles (and their authors)
- [ ] counting hanzi occurences (sort by count) from titles and authors

main activity:

- [ ] rewrite `Upsert` component to accept hanviet
- [ ] implement dict management (for hanviet first)
- [ ] make table comparing multiple hanviet sources
- [ ] implement functionalities to that table

## Backlog

### Frontend

- [ ] cache api requests
- [ ] calling multi (cached) requests in `[chap].svelte`
- [ ] display chap index insides `[chap].svelte` instead of return to info page
- [ ] focus to current page in chap list (save current `scid` in store?)
- [-] add footer (links to facebook page, discord channel, voz page support, tos page, privacy page, donation page etc.)
- [ ] add missing pages (see above), add tips and hints (keyboards support)
- [-] improve ui, make `sort` list <s>and `site` list dropdowns</s>
- [ ] improve `[chap].svelte` responsively, fetch after `onMount` instead of `preload`

### Backend

- [ ] update dicts

  - [x] rewrite import codes, <s>add trad hanzi to `core/common.dic`</s>
  - [-] fix hanviet again (write an ui tool?)
  - [x] prefer hanviet words to extra dicts' words
  - [x] remove unnessary suggestions (hanviet, convertable, low frequency etc.)
  - [ ] add unicode emoji

- [ ] convert engine

  - [x] combines unicode letters and digits
  - [-] fix 69shu title texts
  - [-] handle numbers (datetime, percent, units)
  - [-] apply basic grammar rules

### Both FE and BE

- [x] rewrite FE after BE api changes
- [x] improve search, must be able to jump directly to matched query without having to visit the search result page
- [x] basic authentication system
- [ ] add chap texts manually
- [ ] edit chap texts

- [ ] quick convert (using `book/tonghop.dic`, no saving text)
- [ ] user impressions and trackings
- [ ] dicts management (bulk imports, bulk delete, tranfering etc.)
- [ ] convert web urls?
- [-] fix lookup sidebar: incorrect hanviet range, scroll to focused etc.
- ...

- [ ] analyze texts
  - [ ] analyze chapters, output words count (reject child words with same count)
  - [ ] smart filtering words (remove existed entries)
  - [ ] implement ui for it
