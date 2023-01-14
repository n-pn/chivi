import { get } from 'svelte/store'
import { config } from '$lib/stores'

export function make_url(url: URL, _raw = false) {
  const api_url = new URL(url)
  api_url.pathname = '/api' + url.pathname
  if (_raw) api_url.searchParams.set('_raw', 'true')
  if (get(config).tosimp) api_url.searchParams.set('trad', 'true')

  return api_url.toString()
}
