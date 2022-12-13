import { set_fetch, do_fetch, api_path } from '$lib/api_call'

export async function load({ fetch, params, url: { searchParams } }) {
  set_fetch(fetch)

  const list = params.list.split('-')[0]
  const path = api_path('yslists.show', { list }, searchParams)
  const data = await do_fetch(path)

  const { vname, vdesc } = data.ylist

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

  Object.assign(data, _meta)
  return data
}
