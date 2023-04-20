import type { PageLoad } from './$types'
import { home_nav, book_nav, seed_nav, nav_link } from '$utils/header_util'

export const load = (async ({ url, parent }) => {
  const { nvinfo, curr_seed } = await parent()

  const _meta: App.PageMeta = {
    title: 'Thêm/sửa chương truyện ' + nvinfo.vtitle,
    left_nav: [
      home_nav('', ''),
      book_nav(nvinfo.bslug, '', 'tl'),
      seed_nav(nvinfo.bslug, curr_seed.sname),
      nav_link('+bulk', 'Thêm/sửa chương', 'file-plus', { show: 'pm' }),
    ],
  }

  return {
    _meta,
    start: +url.searchParams.get('start') || 1,
  }
}) satisfies PageLoad
