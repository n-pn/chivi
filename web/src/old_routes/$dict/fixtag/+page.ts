import { rel_time } from '$utils/time_utils'
import { call_api } from '$lib/api_call'

export async function load({ fetch, url }) {
  const source = url.searchParams.get('source') || 'ptags-united'
  const target = url.searchParams.get('target') || 'regular'

  const api_url = `/api/vpinits/fixtag/${source}/${target}`
  const api_res = await fetch(api_url)
  const payload = await api_res.json()
  const topbar = {
    left: [['Phân loại', 'pencil', { href: '.' }]],
  }

  payload['stuff'] = { topbar }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}

export interface Data {
  key: string
  val: string

  uname: string
  mtime: number

  attr: string
  ptags: Record<string, number>
}
