import { redirect } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export interface StemList {
  chivi: CV.Chroot
  draft: CV.Chroot
  users: CV.Chroot[]
  globs: CV.Chroot[]
}

export interface SeedData {
  curr_seed: CV.Chroot
  top_chaps: CV.Wnchap[]
  seed_data: CV.Wnstem
}

export const load = (async ({ url, fetch, params: { wn, stem = '' } }) => {
  const wn_id = parseInt(wn, 10)

  if (!stem.match(/^[~@!+$]/)) {
    const path = url.pathname.replace(`/ch${stem}`, `/ch~chivi`) + url.search
    throw redirect(300, path)
  }

  const list_path = `/_wn/seeds?wn_id=${wn_id}`
  const seed_list = await api_get<StemList>(list_path, fetch)

  const info_path = `/_wn/seeds/${wn_id}/${stem}`
  const seed_data = await api_get<SeedData>(info_path, fetch)

  return { seed_list, ...seed_data }
}) satisfies LayoutLoad
