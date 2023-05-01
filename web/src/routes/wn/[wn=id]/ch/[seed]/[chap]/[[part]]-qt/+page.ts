import { api_get } from '$lib/api_call'
import { chap_path, _pgidx } from '$lib/kit_path'
// import { book_nav, seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'
import { error } from '@sveltejs/kit'

type Data = { cvmtl: string; ztext: string }

export const load = (async ({ parent, params, fetch }) => {
  const pslug = params.part || ''
  const cpart = parseInt(pslug.split('-').pop(), 10) || 1
  const { nvinfo, wnchap } = await parent()

  const hash = wnchap.parts[cpart - 1]
  if (!hash) throw error(404, 'Chương tiết không tồn tại!')

  const p_len = wnchap.parts.length
  const label = p_len > 1 ? `[${cpart}/${p_len}]` : ''

  const path = `/_sp/tl_chap/${hash}?wn_id=${nvinfo.id}&label=${label}`
  const { ztext, cvmtl } = await api_get<Data>(path, fetch)

  return { ztext, cvmtl, cpart, rmode: 'qt' }
}) satisfies PageLoad
