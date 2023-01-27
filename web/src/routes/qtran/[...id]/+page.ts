import { error } from '@sveltejs/kit'
import { make_url } from './shared'

export async function load({ fetch, url, params }) {
  const api_url = make_url(url, true)
  const api_res = await fetch(api_url)

  if (!api_res.ok) throw error(api_res.status, await api_res.text())

  const cvdata = await api_res.text()

  const [type, name] = params.id.split('/')
  return { type, name, cvdata, _path: 'qtran_post' }
}
