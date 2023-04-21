import { redirect } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface SeedData {
  curr_seed: CV.Chroot
  top_chaps: CV.Chinfo[]
  seed_data: CV.WnSeed
}

const prefixes = ['_', '@', '+', '!']

export const load = (async ({ params: { wn, seed }, fetch, url }) => {
  if (!prefixes.includes(seed[0])) {
    const location = url.pathname.replace(`/${seed}`, '/_')
    throw redirect(300, location)
  }

  const path = `/_wn/seeds/${parseInt(wn, 10)}/${seed}`
  return await api_get<SeedData>(path, fetch)
}) satisfies LayoutLoad
