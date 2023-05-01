import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface SeedData {
  curr_seed: CV.Chroot
  top_chaps: CV.Wnchap[]
  seed_data: CV.Wnseed
}

export const load = (async ({ params: { wn, seed }, fetch, url }) => {
  const wn_id = parseInt(wn, 10)

  const path = `/_wn/seeds/${wn_id}/${seed}`
  return await api_get<SeedData>(path, fetch)
}) satisfies LayoutLoad
