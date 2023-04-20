import type { PageLoad } from './$types'

export const load = (async ({ url, params, fetch }) => {
  const path = `/_mt/specs${url.search}`

  // FIXME: add type for api return
  const data = await fetch(path).then((r) => r.json())

  const _meta = {
    title: 'Tổng hợp lỗi máy dịch',
    left_nav: [{ text: 'Lỗi máy dịch', icon: 'flag', href: url.pathname }],
  } satisfies App.PageMeta

  return { ...data, _meta }
}) satisfies PageLoad
