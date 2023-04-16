import { api_path } from '$lib/api_call'
import { nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ fetch, url, params: { author } }) => {
  const extras = { author, lm: 8, order: 'weight' }

  const path = api_path('wnovels.index', null, url.searchParams, extras)
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta: App.PageMeta = {
    title: `Truyện của tác giả: ${author}`,
    left_nav: [
      nav_link('/wn', 'Thư viện', 'books', { show: 'md' }),
      nav_link(`/wn/=${author}`, author, 'edit', { kind: 'title' }),
    ],
  }

  return { ...data, author, _meta }
}) satisfies PageLoad
