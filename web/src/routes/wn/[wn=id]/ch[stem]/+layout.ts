import { redirect } from '@sveltejs/kit'
import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'
import { book_nav, seed_nav, quick_read_v2 } from '$utils/header_util'

export interface StemList {
  wstems: CV.Rdstem[]
  rstems: CV.Rdstem[]
  ustems: CV.Rdstem[]
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
    const path = url.pathname.replace(`/ch${stem}`, `/ch~avail`) + url.search
    throw redirect(300, path)
  }

  const rd_url = `/_rd/bstems/${wn_id}`
  const bstems = await api_get<StemList>(rd_url, fetch)

  const info_path = `/_wn/seeds/${wn_id}/${stem}`
  const seed_data = await api_get<SeedData>(info_path, fetch)

  const _meta = {
    left_nav: [
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tl'),
      seed_nav(nvinfo.bslug, stem, 1, ''),
    ],
    right_nav: [quick_read_v2(nvinfo, ubmemo)],
  }

  return { bstems, ...seed_data, _meta }
}) satisfies LayoutLoad
