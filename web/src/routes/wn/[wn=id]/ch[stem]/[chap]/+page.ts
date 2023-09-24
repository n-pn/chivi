import type { PageLoad } from './$types'
import { get_nctext_mtran } from '$utils/tran_util'

export const load = (async ({ fetch, parent, depends }) => {
  const { rdata, xargs } = await parent()
  depends('wn:cdata')

  const cpath = `${rdata.cbase}-${xargs.cpart}`
  const _algo = xargs.rmode

  return await get_nctext_mtran(cpath, true, _algo, 'force-cache', fetch)
}) satisfies PageLoad
