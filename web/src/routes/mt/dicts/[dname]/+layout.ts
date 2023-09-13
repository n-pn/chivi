import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface DictData {
  dinfo: CV.Vidict
  users: string[]
  // terms: CV.Viterm[]
}

export const load = (async ({ fetch, params: { dname } }) => {
  const { dinfo, users } = await api_get<DictData>(`/_ai/dicts/${dname}`, fetch)
  return { dname, dinfo, users }
}) satisfies LayoutLoad
