# crawl grades
# - 5: existed on chivi book db, on users' libraries, ongoing
# - 4: existed on chivi book db, on users' libraries but book completed/axed, or ongoing but not on any collections
# - 3: not existed in chivi book db, but book author is on chivi db author table
# - 2: not existed in chivi book db, existed on original website (not 404)
# - 1: id checked, but not return valid result (404 or 500)
# - 0: default initial state
# NOTE: will be added to chivi db if author and btitle is an exact match to existing entry.
