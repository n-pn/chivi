import type { LoadEvent } from '@sveltejs/kit'
import type { Data } from './shared'

export async function load({ fetch, url }: LoadEvent) {
  const source = url.searchParams.get('source') || 'ptags-united'
  const target = url.searchParams.get('target') || 'regular'

  const api_url = `/api/vpinits/fixtag/${source}/${target}`
  const content: Data[] = await fetch(api_url).then((r) => r.json())

  const data = { content, source, target, _meta: null }

  data._meta = {
    title: 'Sửa phân loại',
    left_nav: [{ text: 'Phân loại', icon: 'pencil', href: '.' }],
  } satisfies App.PageMeta

  return data
}
