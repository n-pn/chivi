import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'
import { error } from '@sveltejs/kit'

type Data = { btran: string[]; ztext: string[]; mtime: number }

export const load = (async ({ parent, params, fetch }) => {
  const pslug = params.part || ''
  const cpart = parseInt(pslug.split('-').pop(), 10) || 1
  const { chdata } = await parent()

  const cksum = chdata.cksum
  if (!cksum) throw error(404, 'Chương tiết không tồn tại!')

  const cpath = `${chdata.cbase}_${cpart}-${chdata.cksum}`
  const bvurl = `/_sp/bing_chap?cpath=${cpath}`

  const { btran, ztext, mtime } = await api_get<Data>(bvurl, fetch)
  return { btran, ztext, mtime, cpart, rmode: 'bv' }
}) satisfies PageLoad
