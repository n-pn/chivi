import { api_get } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export const load: LayoutLoad = async ({ fetch, params: { dt_id } }) => {
  const path = `/_db/topics/${dt_id}`
  const cvpost = await api_get<CV.DtopicFull>(path, fetch)
  return { cvpost }
}
