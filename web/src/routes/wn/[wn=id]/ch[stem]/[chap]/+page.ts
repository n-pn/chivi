import type { PageLoad } from './$types'
import { get_nctext_mtran } from '$utils/tran_util'

export const load = (async ({ url, fetch, parent, depends }) => {
  depends('wn:cdata')
  const { xargs, error } = await parent()

  if (error) {
    const vtran = { lines: [], error: 'n/a' }
    return { vtran }
  }

  const _algo = url.searchParams.get('mode') || xargs._algo || 'avail'
  const spath = xargs.spath
  const vtran = await get_nctext_mtran(spath, true, _algo, 'default', fetch)
  return { vtran }
}) satisfies PageLoad
