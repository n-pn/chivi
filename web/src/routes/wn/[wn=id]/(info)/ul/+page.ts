import { load_lists } from '$lib/fetch_data'
import { home_nav, book_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const { nvinfo, _user } = await parent()
  if (_user.privi < 1) url.searchParams.append('from', 'vi')

  const data = await load_lists(url, fetch, { book: nvinfo.id })
  const _meta: App.PageMeta = build_meta(nvinfo)

  return {
    ...data,
    ontab: 'ul',
    _meta,
    _title: nvinfo.vtitle,
    _mdesc: nvinfo.bintro.substring(0, 300),
  }
}) satisfies PageLoad

const build_meta = (book: CV.Wninfo) => {
  return {
    left_nav: [
      book_nav(book.bslug, book.vtitle, 'ts'),
      nav_link('lists', 'Thư đơn', 'bookmarks', { show: 'pm' }),
    ],
  }
}
