import { api_get } from '$lib/api_call'
import { redirect } from '@sveltejs/kit'

import type { LayoutLoad } from './$types'

export interface SeedData {
  curr_seed: CV.Chroot
  top_chaps: CV.Wnchap[]
  seed_data: CV.Wnstem
}

export const load = (async ({ params: { wn, seed }, fetch, url }) => {
  if (seed == '_' || seed[0] == '=') {
    const new_path = url.pathname.replace(/ch\/\w+/, 'ch/~draft')
    if (new_path != url.pathname) throw redirect(301, new_path)
  }

  const wn_id = parseInt(wn, 10)
  const path = `/_wn/seeds/${wn_id}/${seed}`
  return await api_get<SeedData>(path, fetch)
}) satisfies LayoutLoad
