import { api_get } from '$lib/api_call'
import { chap_path, _pgidx } from '$lib/kit_path'
// import { book_nav, seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

type Data = { cvmtl: string; ztext: string }

export const load = (async ({ parent, params, fetch }) => {
  const { nvinfo, chdata } = await parent()

  const cpart = parseInt((params.part || '').split('-').pop(), 10) || 1
  const cpath = `${chdata.cbase}_${cpart}`

  const label = chdata.psize > 1 ? `[${cpart}/${chdata.psize}]` : ''

  const qturl = `/_sp/tl_chap?cpath=${cpath}&wn_id=${nvinfo.id}&label=${label}`
  const { ztext, cvmtl } = await api_get<Data>(qturl, fetch)

  return { ztext, cvmtl, cpart, rmode: 'qt' }
}) satisfies PageLoad
