import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'

type Data = { btran: string[]; ztext: string[]; mtime: number }

export const load = (async ({ parent, params, fetch }) => {
  const { chdata } = await parent()

  const cpart = parseInt((params.part || '').split('-').pop(), 10) || 1

  const bvurl = `/_sp/bing_chap?cpath=${chdata.cbase}-${cpart}`
  const { btran, ztext, mtime } = await api_get<Data>(bvurl, fetch)

  return { btran, ztext, mtime, cpart, rmode: 'bv' }
}) satisfies PageLoad
