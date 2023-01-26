// export const ssr = false

import { redirect } from '@sveltejs/kit'
import { set_fetch, api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

const prefixes = ['_', '@', '+', '!']

export interface SeedData {
  _seed: CV.Chroot
  lasts: CV.Chinfo[]

  stime: number
  slink: string
  fresh: boolean

  privi_map: number[]
}
export const load = (async ({ params, fetch, url }) => {
  const [sname, s_bid] = params.sname.split(':')

  if (!prefixes.includes(sname[0])) {
    const location = url.pathname.replace(`/${sname}`, '/-')
    throw redirect(300, location)
  }

  set_fetch(fetch)

  const api_url = `/_wn/seeds/${sname}/${s_bid || params.wn_id}`
  return { _curr: await api_get<SeedData>(api_url) }
}) satisfies LayoutLoad
