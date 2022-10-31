const icons = {
  notes: 'notes',
  posts: 'user',
  links: 'link',
  crits: 'stars',
}

import { get } from 'svelte/store'
import { config } from '$lib/stores'

function make_url(url: URL, _raw = false) {
  const api_url = new URL(url)
  api_url.pathname = '/api/' + url.pathname
  if (_raw) api_url.searchParams.set('_raw', 'true')
  if (get(config).tosimp) api_url.searchParams.set('trad', 'true')

  return api_url.toString()
}

export async function load({ fetch, url, params }) {
  const api_url = make_url(url, true)
  const api_res = await fetch(api_url)
  const payload = await api_res.text()

  if (!api_res.ok) throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { status: api_res.status, error: payload }

  const [type, name] = params.id.split('/')

  const topbar = {
    left: [
      ['Dịch nhanh', 'bolt', { href: '/qtran', show: 'ts' }],
      [`[${name}]`, icons[type], { href: name, kind: 'title' }],
    ],
    config: true,
  }

  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return { props: { type, name, cvdata: payload }, stuff: { topbar } }
}
