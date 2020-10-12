# TODO

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
  - [ ] add kaomoji?

- [ ] convert engine

  - [x] combines unicode letters and digits
  - [-] fix 69shu title texts
    - [ ] to be recheck
    - [ ] change chap number index?
  - [-] handle numbers (datetime, percent, units)
  - [-] apply basic grammar rules
    - [x] many
    - [-] handle datetime, need to merge year month day to single word
    - [ ] handle hours and minutes

### Both FE and BE

- [x] rewrite FE after BE api changes
- [x] improve search, must be able to jump directly to matched query without having to visit the search result page
- [x] basic authentication system

- [ ] add chap texts manually
- [ ] edit chap texts

- [ ] quick convert (using `book/dich-nhanh.dic`, no saving text)
- [ ] translate websites?

- [-] user impressions and trackings

  - [x] book library (marking `ongoing`, `completed`, etc.)
  - [ ] tracking chapter read, make chapter bookmark to quick re-read jump

- [ ] dicts management (bulk imports, bulk delete, tranfering etc.)

- [-] fix lookup sidebar:

  - [x] incorrect hanviet range
  - [ ] scroll to focused .

- ...

- [ ] analyze texts
  - [ ] analyze chapters, output words count (reject child words with same count)
  - [ ] smart filtering words (remove existed entries)
  - [ ] implement ui for it

### Pending

- [ ] add background images for pages
      pick first book cover image for book lists pages

  TODO: figure out how to apply body background-image from routes

  references:

  - https://stackoverflow.com/questions/26621513/darken-css-background-image

- [ ] using user name as primary key for users related records
- [ ] using book slug instead of uuid for dict names and other indexes

- [ ] automatically add words to `suggest.dic` and `dich-nhanh.dic`
- [ ] add context for upsert keys (add more text files?)

## Current

### Fix hanviet

prepare:

- [x] make `hanviet` dictionary access/editable by moderators
- [ ] extract list of most 20k popular book titles (and their authors)
- [ ] counting hanzi occurences (sort by count) from titles and authors

main activity:

- [x] rewrite `Upsert` component to accept hanviet
- [ ] implement dict management (for hanviet first)
- [ ] make table comparing multiple hanviet sources
- [ ] implement functionalities to that table

### Fix upsert dialog

- [ ] instead of providing the exact hanzi string, rewrite it by providing the whole line and range indexes instead
- [ ] add button to move focus
- [ ] add keyboard shortcut to move focus

## Performance improvement

- [ ] tweak order_map performance
- [ ] split chap heads to label_maps instead of keeping it in a huge json file

## Refactoring

- [ ] using seconds instead of milliseconds for mftimes
- [ ] using minutes in book access/ book update order_maps for practical reason
