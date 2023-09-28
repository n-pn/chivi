import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'

export const load = (async ({ parent, fetch }) => {
  const { xargs } = await parent()
  xargs.rtype = 'qt'

  return { xargs }
}) satisfies PageLoad
