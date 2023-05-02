import { api_get } from '$lib/api_call'
import type { LayoutData } from './$types'

export const load = (async ({ fetch, params: { user } }) => {
  const path = `/_db/users/${user}`
  const viuser = await api_get<CV.Viuser>(path, fetch)

  return { viuser }
}) satisfies LayoutData
