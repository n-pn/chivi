import { api_get } from '$lib/api_call'
import { chap_path, _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'
import { error } from '@sveltejs/kit'

type Data = { cvmtl: string; ztext: string }

export const load = (async ({ parent, params, fetch }) => {
  const pslug = params.part || ''
  const cpart = parseInt(pslug.split('-').pop(), 10) || 1
  const { nvinfo, wnchap } = await parent()

  const hash = wnchap.parts[cpart - 1]
  if (!hash) throw error(404, 'Chương tiết không tồn tại!')

  return { cpart, rmode: 'tl' }
}) satisfies PageLoad
