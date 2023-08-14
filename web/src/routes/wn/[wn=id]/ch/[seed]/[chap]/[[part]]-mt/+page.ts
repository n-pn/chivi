import { api_get } from '$lib/api_call'
// import { _pgidx } from '$lib/kit_path'
// import { book_nav, seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'
import { error } from '@sveltejs/kit'

export const load = (async ({ parent, params, fetch }) => {
  const { nvinfo, chdata } = await parent()

  if (!chdata.cksum) throw error(403, 'Chương tiết không tồn tại!')

  const pslug = params.part || ''
  const cpart = parseInt(pslug.split('-').pop(), 10) || 1

  const { ztext, cvmtl } = await load_data(fetch, chdata, cpart, nvinfo.id)

  return { ztext, cvmtl, cpart, rmode: 'mt' }
}) satisfies PageLoad

async function load_data(
  fetch: CV.Fetch,
  chdata: CV.Chdata,
  cpart = 1,
  wn_id = 0
) {
  const p_len = chdata.sizes.length - 1
  const label = p_len > 1 ? `[${cpart}/${p_len}]` : ''

  const cpath = `${chdata.cbase}_${cpart}-${chdata.cksum}`
  const mturl = `/_m1/qtran/wnchap?cpath=${cpath}&wn_id=${wn_id}&label=${label}`

  return await api_get<{ cvmtl: string; ztext: string }>(mturl, fetch)
}
