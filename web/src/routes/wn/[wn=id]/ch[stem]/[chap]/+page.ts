import type { PageLoad } from './$types'
import { get_nctext_mtran } from '$utils/tran_util'

export const load = (async ({ fetch, parent, depends }) => {
  depends('wn:cdata')
  const { xargs } = await parent()
  const { spath, _algo } = xargs
  const vtran = await get_nctext_mtran(spath, true, _algo, 'force-cache', fetch)
  return { vtran }
}) satisfies PageLoad
