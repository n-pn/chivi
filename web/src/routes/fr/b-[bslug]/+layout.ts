import { api_get } from '$lib/api_call'
import type { LoadEvent } from '@sveltejs/kit'

export const load = async ({ fetch, params: { bslug } }: LoadEvent) => {
  const board_id = parseInt(bslug)
  const dboard = await api_get<CV.Dboard>(`/_db/boards/${board_id}`, fetch)
  return { dboard }
}
