import type { PageLoad } from './$types'
import { call_mtran_file } from '$utils/tran_util'

export const load = (async ({ url, fetch, parent, depends, params }) => {
  depends('wn:cdata')
  const { xargs, error } = await parent()
  if (error) return { vtran: { lines: [], error: 'n/a' } }

  const pdict = 'up/' + params.id
  const m_alg = url.searchParams.get('mode') || xargs.m_alg || 'avail'
  const finit = { fpath: xargs.spath, ftype: 'up', pdict, m_alg, force: true }

  const vtran = await call_mtran_file(finit, { cache: 'default' }, fetch)
  return { vtran }
}) satisfies PageLoad
