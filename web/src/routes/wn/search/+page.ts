import { nav_link } from '$gui/global/header_util'
import { api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ fetch, url: { searchParams } }) => {
  const type = searchParams.get('t') || 'btitle'
  const input = searchParams.get('q').replace('+', ' ')

  const extras = { order: 'weight', lm: 8, [type]: input }

  const path = api_path('wnovels.index', null, searchParams, extras)
  const data: JsonData = await fetch(path).then((x) => x.json())

  const _meta: App.PageMeta = {
    title: `Kết quả tìm kiếm cho "${input}"`,
    left_nav: [
      nav_link('/wn', 'Thư viện', 'books', { show: 'md' }),
      nav_link('/wn/search', 'Tìm kiếm', 'search', { kind: 'title' }),
    ],
  }

  return { ...data, input, type, _meta }
}) satisfies PageLoad
