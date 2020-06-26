# TODO

## Frontend

-   [ ] cache api requests
-   [ ] calling multi (cached) requests in `[chap].svelte`
-   [ ] display chap index insides `[chap].svelte` instead of return to info page
-   [ ] focus to current page in chap list (save current `csid` in store)
-   [ ] add footer (links to facebook page, discord channel, voz page support, tos page, privacy page, donation page etc.)
-   [ ] add missing pages (see above), add tips and hints (keyboards support)
-   [ ] improve ui, make `sort` list and `site` list dropdowns
-   [ ] improve `[chap].svelte` responsively, fetch after `onMount` instead of `preload`

## Backend

-   [ ] make it works again

    -   [ ] polish `serial.cr` and fix `source.cr`, rename `serial` to `title`?
    -   [ ] combine `zh_list` and `zh_text`, add `convert_by` and `convert_at` metadata
    -   [ ] rebuild books assets
    -   [ ] finish rewrite book_indexes and rebuild book_indexes

-   [ ] combine zh_texts with vp_texts

    -   [ ] combine files
    -   [ ] rewrite chap_repo, add meta data (convert_by user, converted_at time, etc.)
    -   [ ] replace SEP0 and SEP1 to unicode alternatives in input text for correctness

-   [ ] update dicts

    -   [ ] rewrite import codes, add trad hanzi to `core/common.dic`
    -   [ ] fix hanviet again (write an ui tool?)
    -   [ ] prefer hanviet words to extra dicts' words
    -   [ ] move `core/combine.dic` to `book/tonghop.dic`
    -   [ ] add common words (datetime, percents)
    -   [ ] remove unnessary suggestions (hanviet, convertable, low frequency etc.)

-   [ ] convert engine

    -   [ ] combines non-latin letters (e.g. hiragana)
    -   [ ] fix 69shu title texts
    -   [ ] apply basic grammar rules

## Both FE and BE

-   [ ] rewrite FE after BE api changes
-   [ ] improve search, must be able to jump directly to matched query without having to visit the search result page
-   [ ] add custom texts (single chapter or many)
-   [ ] edit raw texts

-   [ ] quick convert (using `book/tonghop.dic`, no saving text)
-   [ ] basic authentication system
-   [ ] user impressions and trackings
-   [ ] dicts management (bulk imports, bulk delete, tranfering etc.)
-   [ ] convert websites?
-   ...

-   [ ] analyze texts
    -   [ ] analyze chapters, output words count (reject child words with same count)
    -   [ ] smart filtering words (remove existed entries)
    -   [ ] implement ui
