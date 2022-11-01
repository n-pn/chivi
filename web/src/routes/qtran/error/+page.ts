export async function load({ fetch, url }) {
  const api_res = await fetch(`/api/tlspecs${url.search}`)

  // FIXME: add type for api return
  const { pgidx, pgmax, items } = await api_res.json()

  const _meta: App.PageMeta = {
    title: 'Tổng hợp lỗi máy dịch',
    left_nav: [{ text: 'Lỗi máy dịch', icon: 'flag', href: url.pathname }],
  }

  return { pgidx, pgmax, items, _meta }
}
