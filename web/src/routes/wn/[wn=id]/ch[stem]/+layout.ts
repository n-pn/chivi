import { api_get } from '$lib/api_call'
import { redirect } from '@sveltejs/kit'
import { book_nav, seed_nav, quick_read_v2 } from '$utils/header_util'

import type { LayoutLoad } from './$types'

export interface StemList {
  wstems: CV.Chstem[]
  rstems: CV.Chstem[]
  ustems: CV.Chstem[]
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

  const wnurl = `/_rd/wnstems/${stem}/${wn_id}`
  const wstem = await api_get<CV.Wnstem>(wnurl, fetch)

  const _meta = {
    left_nav: [
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tl'),
      seed_nav(nvinfo.bslug, stem, 1, ''),
    ],
  }

  return { bstems, wstem, _meta }
}) satisfies LayoutLoad
