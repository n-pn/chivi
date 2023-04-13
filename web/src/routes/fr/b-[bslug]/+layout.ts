import { api_get } from '$lib/api_call'
import type { LoadEvent } from '@sveltejs/kit'

export const load = async ({ fetch, params: { bslug } }: LoadEvent) => {
  const dboard = await api_get<CV.Dboard>(`/_db/boards/${bslug}`, fetch)
  return { dboard }
}
