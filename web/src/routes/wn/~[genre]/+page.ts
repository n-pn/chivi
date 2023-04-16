import { api_path } from '$lib/api_call'
import { nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ fetch, url, params: { genre } }) => {
  const extras = { lm: 24, order: 'weight', genres: genre }
  const path = api_path('wnovels.index', null, url.searchParams, extras)

  console.log({ path })
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta = {
    title: 'Lọc truyện theo thể loại',
    left_nav: [
      nav_link('/wn', 'Thư viện', 'books', { show: 'md' }),
      nav_link(url.pathname, 'Thể loại', 'folder', { kind: 'title' }),
    ],
  }

  return { ...data, genres: genre.split('+'), _meta }
}) satisfies PageLoad
