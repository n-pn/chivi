import { api_path } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

export async function load({ fetch, url }: PageLoadEvent) {
  const path = api_path('tlspec.index', null, url.searchParams)

  // FIXME: add type for api return
  const data = await fetch(path).then((r) => r.json())

  data._meta = {
    title: 'Tổng hợp lỗi máy dịch',
    left_nav: [{ text: 'Lỗi máy dịch', icon: 'flag', href: url.pathname }],
  } satisfies App.PageMeta

  return data
}
