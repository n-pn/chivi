import { api_get } from '$lib/api'

export async function load({ fetch, params, url }) {
  const id = params.list.split('-')[0]
  const api_url = `/_ys/lists/${id}${url.search}`
  const api_res = await api_get(api_url, null, fetch)
  const { vname, vdesc } = api_res.ylist

  // prettier-ignore
  const _meta : App.PageMeta = {
    title: `Thư đơn: ${vname}`,
    desc: vdesc,
    left_nav: [
      { text: 'Thư đơn', icon: 'bookmarks', href: '/ys/lists' },
      { text: vname, href: '.', 'data-kind': 'title' }
    ],
    right_nav: [{text: 'Đánh giá', icon: 'stars', href: '/ys/crits', 'data-show': 'tm' }],
  }

  return { ...api_res, _meta }
}
