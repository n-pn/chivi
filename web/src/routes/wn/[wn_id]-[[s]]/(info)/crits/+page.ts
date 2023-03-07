import type { PageLoad } from './$types'

import { load_crits } from '$lib/fetch_data'

export const load = (async ({ url, fetch, params }) => {
  return await load_crits(url, fetch, params.wn_id)
}) satisfies PageLoad
