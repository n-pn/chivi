import { redirect } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface SeedData {
  curr_seed: CV.Chroot
  top_chaps: CV.Chinfo[]
  seed_data: CV.WnSeed
}

const prefixes = ['_', '@', '+', '!']

export const load = (async ({ params: { wn_id, seed }, fetch, url }) => {
  if (!prefixes.includes(seed[0])) {
    const location = url.pathname.replace(`/${seed}`, '/_')
    throw redirect(300, location)
  }

  const api_url = `/_wn/seeds/${wn_id}/${seed}`
  return await api_get<SeedData>(api_url, fetch)
}) satisfies LayoutLoad
