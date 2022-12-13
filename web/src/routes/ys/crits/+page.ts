import { api_path } from '$lib/api_call'

// prettier-ignore
const _meta = {
  title: 'Đánh giá',
  left_nav: [{ text: 'Đánh giá', icon: 'stars', href: '/ys/crits' }],
  right_nav: [{text: 'Thư đơn', icon: 'bookmarks', href: '/ys/lists', 'data-show': 'tm' }],
}

export async function load({ fetch, url: { searchParams } }) {
  const path = api_path('yscrits.index', null, searchParams, { take: 10 })
  const data = await fetch(path).then((r: Response) => r.json())

  data._meta = _meta
  return data
}
