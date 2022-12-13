import { set_fetch, do_fetch, api_path } from '$lib/api_call'

// prettier-ignore
const _meta : App.PageMeta = {
  title: 'Thư đơn',
  left_nav: [{text: 'Thư đơn', icon: 'bookmarks',  href: '/ys/lists' }],
  right_nav: [{text: 'Đánh giá', icon: 'stars',  href: '/ys/crits', 'data-show': 'tm' }],
}

export async function load({ fetch, url: { searchParams } }) {
  set_fetch(fetch)

  const path = api_path('yslists.index', {}, searchParams, { take: 10 })
  const data = await do_fetch(path)

  return { ...data, params: Object.fromEntries(searchParams), _meta }
}
