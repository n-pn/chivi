export async function load({ fetch, params, url }) {
  const id = params.list.split('-')[0]
  const api_url = `/_ys/lists/${id}${url.search}`
  const api_res = await fetch(api_url)

  const props = await api_res.json()

  const topbar = {
    left: [
      ['Thư đơn', 'bookmarks', { href: '/lists' }],
      [props.ylist.vname, null, { href: '.', kind: 'title' }],
    ],

    right: [['Đánh giá', 'stars', { href: '/crits', show: 'tm' }]],
  }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props, stuff: { topbar } }
}
