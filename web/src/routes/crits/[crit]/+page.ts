export async function load({ fetch, params: { crit } }) {
  const api_res = await fetch(`/_ys/crits/${crit}`)
  const { entry } = await api_res.json()

  const _meta: App.PageMeta = {
    title: 'Đánh giá',
    left_nav: [
      { text: 'Đánh giá', icon: 'stars', href: '/crits' },
      { 'text': `[${crit}]`, 'href': '/.', 'data-kind': 'zseed' },
    ],
    // prettier-ignore
    right_nav: [{text: 'Thư đơn', icon: 'bookmarks', href: '/lists', 'data-show': 'tm' }],
  }

  return { entry, _meta }
}
