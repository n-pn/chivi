import { api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load: PageLoad = async ({ fetch, params: { crit } }) => {
  const path = api_path('yscrits.show', crit)
  const data = await fetch(path).then((r) => r.json())

  const _meta = {
    title: 'Đánh giá',
    left_nav: [
      { text: 'Đánh giá', icon: 'stars', href: '/ys/crits' },
      { 'text': `[${crit}]`, 'href': '/.', 'data-kind': 'zseed' },
    ],
    // prettier-ignore
    right_nav: [{text: 'Thư đơn', icon: 'bookmarks', href: '/ys/lists', 'data-show': 'tm' }],
  } satisfies App.PageMeta

  return { ...data, _meta }
}
