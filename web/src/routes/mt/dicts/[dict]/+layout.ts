import { api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'

export interface DictData {
  dinfo: CV.Zvdict
  users: string[]
  // terms: CV.Zvdefn[]
}

export const load = (async ({ fetch, params: { dict } }) => {
  const { dinfo, users } = await api_get<DictData>(`/_sp/dicts/${dict}`, fetch)
  return { dict, dinfo, users }
}) satisfies LayoutLoad
