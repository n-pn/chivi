const _meta = {
  title: 'Tổng hợp lỗi máy dịch',
}

export async function load({ fetch, url }) {
  const api_res = await fetch(`/api/tlspecs${url.search}`)
  const { pgidx, pgmax, items } = await api_res.json()

  const _head_left = [
    { text: 'Lỗi máy dịch', icon: 'flag', href: url.pathname },
  ]

  return { _meta, _head_left, pgidx, pgmax, items }
}
