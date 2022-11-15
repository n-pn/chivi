import { api_get } from '$lib/api'
// prettier-ignore
const _meta : App.PageMeta = {
  title: 'Thư đơn',
  left_nav: [{text: 'Thư đơn', icon: 'bookmarks',  href: '/lists' }],
  right_nav: [{text: 'Đánh giá', icon: 'stars',  href: '/crits', 'data-show': 'tm' }],
}

export async function load({ fetch, url: { searchParams } }) {
  const api_url = `/_ys/lists?${searchParams.toString()}&take=10`
  const api_res = await api_get(api_url, null, fetch)

  // FIXME:
  // - remove props
  // - add interface

  const params = Object.fromEntries(searchParams)

  return { ...api_res, params, _meta }
}
