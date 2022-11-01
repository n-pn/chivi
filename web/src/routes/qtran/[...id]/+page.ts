import { error } from '@sveltejs/kit'
import { make_url } from './shared'

const qtran_icons = {
  notes: 'notes',
  posts: 'user',
  links: 'link',
  crits: 'stars',
}

export async function load({ fetch, url, params }) {
  const api_url = make_url(url, true)
  const api_res = await fetch(api_url)

  if (!api_res.ok) throw error(api_res.status, await api_res.text())

  const cvdata = await api_res.text()
  const [type, name] = params.id.split('/')

  // prettier-ignore
  const _meta : App.PageMeta = {
    title: 'Dịch nhanh: ' + name,
    desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
    left_nav: [
      { text: 'Dịch nhanh', icon: 'bolt', href: '/qtran', 'data-show': 'ts' },
      { text: `[${name}]`, icon: qtran_icons[type], href: name, 'data-kind': 'title' },
    ],
    show_config: true,
  }

  return { type, name, cvdata, _meta }
}
