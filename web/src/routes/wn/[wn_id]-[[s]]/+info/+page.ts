import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ params, fetch }) => {
  const href = `/_db/books/${params.wn_id}/edit_form`
  return { wnform: api_get<CV.WnForm>(href, fetch) }
}) satisfies PageLoad
