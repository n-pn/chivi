import type { PageLoad } from './$types'
import { call_mtran_file } from '$utils/tran_util'

export const load = (async ({ url, fetch, parent, depends }) => {
  depends('wn:cdata')
  const { xargs, error } = await parent()
  if (error) return { vtran: { lines: [], error: 'n/a' } }

  const m_alg = url.searchParams.get('mode') || xargs.m_alg || 'avail'

  const pdict = 'up/' + xargs.up_id
  const finit = { fpath: xargs.spath, ftype: 'up', pdict, m_alg, force: true }

  const vtran = await call_mtran_file(finit, { cache: 'default' }, fetch)
  return { vtran }
}) satisfies PageLoad
