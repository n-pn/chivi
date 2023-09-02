import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'

type Data = { cvmtl: string; ztext: string; cdata: string; _algo: string }

export const load = (async ({ parent, params, fetch }) => {
  const { nvinfo, chdata } = await parent()

  const cpart = parseInt((params.part || '').split('-').pop(), 10) || 1
  const cpath = `${chdata.cbase}-${cpart}`

  const qturl = `/_ai/qtran/wnchap?cpath=${cpath}&pdict=book/${nvinfo.id}`
  const data = await api_get<Data>(qturl, fetch)

  return { ...data, cpart, rmode: 'ai' }
}) satisfies PageLoad
