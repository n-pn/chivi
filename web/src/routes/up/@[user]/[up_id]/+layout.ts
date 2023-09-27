import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export interface StemData {
  ustem: CV.Upstem
  chaps: CV.Wnchap[]
}

export const load = (async ({ fetch, params }) => {
  const uname = params.user
  const up_id = parseInt(params.up_id, 10)

  const { ustem, chaps } = await api_get<StemData>(`/_up/stems/${up_id}`, fetch)
  return { ustem, lasts: chaps, up_id, uname }
}) satisfies LayoutLoad
