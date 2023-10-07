import { redirect } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'
import { book_nav, seed_nav, quick_read_v2 } from '$utils/header_util'

export interface StemList {
  chivi: CV.Chroot
  draft: CV.Chroot
  avail: CV.Chroot
  globs: CV.Chroot[]
}

export interface SeedData {
  curr_seed: CV.Chroot
  top_chaps: CV.Wnchap[]
  seed_data: CV.Wnstem
}

export const load = (async ({ url, fetch, params: { stem = '' }, parent }) => {
  const { nvinfo, ubmemo } = await parent()
  const wn_id = nvinfo.id

  if (!stem.match(/^[~@!+$]/)) {
    const path = url.pathname.replace(`/ch${stem}`, `/ch~chivi`) + url.search
    throw redirect(300, path)
  }

  const list_path = `/_wn/seeds?wn_id=${wn_id}`
  const seed_list = await api_get<StemList>(list_path, fetch)

  const info_path = `/_wn/seeds/${wn_id}/${stem}`
  const seed_data = await api_get<SeedData>(info_path, fetch)

  const up_api = `/_rd/upstems?wn=${wn_id}`
  const { items: ustems } = await api_get<{ items: CV.Upstem[] }>(up_api, fetch)

  const _meta = {
    left_nav: [
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tl'),
      seed_nav(nvinfo.bslug, stem, 1, ''),
    ],
    right_nav: [quick_read_v2(nvinfo, ubmemo)],
  }

  return { seed_list, ustems, ...seed_data, _meta }
}) satisfies LayoutLoad
