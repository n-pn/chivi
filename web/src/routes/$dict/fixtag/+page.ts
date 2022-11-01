import type { Data } from './shared'

export async function load({ fetch, url }) {
  const source = url.searchParams.get('source') || 'ptags-united'
  const target = url.searchParams.get('target') || 'regular'

  const api_url = `/api/vpinits/fixtag/${source}/${target}`
  const api_res = await fetch(api_url)
  const content: Data[] = (await api_res.json()).props

  const _meta = {
    title: 'Sửa phân loại',
    left_nav: [{ text: 'Phân loại', icon: 'pencil', href: '.' }],
  }

  return { content, source, target, _meta }
}
