import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'
import { error } from '@sveltejs/kit'

type Data = { btran: string[]; ztext: string[]; mtime: number }

export const load = (async ({ parent, params, fetch }) => {
  const pslug = params.part || ''
  const cpart = parseInt(pslug.split('-').pop(), 10) || 1
  const { wnchap } = await parent()

  const hash = wnchap.parts[cpart - 1]
  if (!hash) throw error(404, 'Chương tiết không tồn tại!')

  const path = `/_sp/bing_chap/${hash}`
  const data = await api_get<Data>(path, fetch)
  return { ...data, cpart, rmode: 'bv' }
}) satisfies PageLoad
