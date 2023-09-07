import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'
import type { Cdata } from '$lib/mt_data_2'
import { error } from '@sveltejs/kit'

export const load = (async ({ parent, params, fetch }) => {
  const { nvinfo, chdata } = await parent()

  const cpart = parseInt((params.part || '').split('-').pop(), 10) || 1
  const cpath = `${chdata.cbase}-${cpart}`

  const url = `/_ai/qtran/wnchap?cpath=${cpath}&pdict=book/${nvinfo.id}`
  const res = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
  })

  if (!res.ok) throw error(res.status, await res.text())

  const cdata = (await res.json()) as Array<Cdata>
  const _algo = res.headers['_ALGO'] || ''

  return { cdata, _algo, cpart, rmode: 'ai' }
}) satisfies PageLoad
