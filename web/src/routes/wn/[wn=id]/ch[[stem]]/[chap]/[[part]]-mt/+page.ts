import { api_get } from '$lib/api_call'
// import { _pgidx } from '$lib/kit_path'
// import { book_nav, seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'
import { error } from '@sveltejs/kit'

export const load = (async ({ parent, params, fetch }) => {
  const { nvinfo, chdata } = await parent()

  const cpart = parseInt((params.part || '').split('-').pop(), 10) || 1
  const { ztext, cvmtl } = await load_data(fetch, chdata, cpart, nvinfo.id)

  return { ztext, cvmtl, cpart, rmode: 'mt' }
}) satisfies PageLoad

async function load_data(fetch: CV.Fetch, chap: CV.Chdata, part = 1, book = 0) {
  const label = chap.psize > 1 ? `[${part}/${chap.psize}]` : ''

  const cpath = `${chap.cbase}-${part}`
  const mturl = `/_m1/qtran/wnchap?cpath=${cpath}&wn_id=${book}&label=${label}`

  return await api_get<{ cvmtl: string; ztext: string }>(mturl, fetch)
}
