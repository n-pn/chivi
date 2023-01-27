import { redirect } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface SeedData {
  curr_seed: CV.Chroot
  top_chaps: CV.Chinfo[]

  seed_data: {
    stime: number
    slink: string
    fresh: boolean
    //
    min_privi: number
    privi_map: number[]
  }
}

const prefixes = ['_', '@', '+', '!']

export const load = (async ({ params, fetch, url }) => {
  const wn_id = params.bname.split('-')[0]
  const [sname, s_bid = wn_id] = params.sname.split(':')

  if (!prefixes.includes(sname[0])) {
    const location = url.pathname.replace(`/${sname}`, '/_')
    throw redirect(300, location)
  }

  const api_url = `/_wn/seeds/${sname}/${s_bid}`

  return await api_get<SeedData>(api_url, null, fetch)
}) satisfies LayoutLoad
