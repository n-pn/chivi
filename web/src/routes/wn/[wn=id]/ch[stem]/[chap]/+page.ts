import type { PageLoad } from './$types'
import { call_mt_ai_file } from '$utils/tran_util'

export const load = (async ({ url, fetch, parent, depends }) => {
  depends('wn:cdata')

  const { xargs, error } = await parent()
  if (error) return { vtran: { lines: [], error: 'n/a' } }

  const m_alg = url.searchParams.get('mode') || xargs.m_alg || 'avail'
  const finit = { ...xargs.zpage, m_alg, force: true }

  const vtran = await call_mt_ai_file(finit, { cache: 'default' }, fetch)
  return { vtran }
}) satisfies PageLoad
