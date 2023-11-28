import { _pgidx } from '$lib/kit_path'
import type { PageLoad } from './$types'

const gen_pdict = ({ stype, wn_id, sn_id }) => {
  if (wn_id > 0) return `book/${wn_id}`
  if (stype == 1) return `up/${sn_id}`
  return 'combine'
}

export const load = (async ({ url, parent }) => {
  const { rdata, crepo } = await parent()

  const ropts = {
    fpath: rdata.fpath,
    pdict: gen_pdict(crepo),
    wn_id: crepo.wn_id,
    rmode: url.searchParams.get('rm') || 'qt',
    qt_rm: url.searchParams.get('qt') || 'qt_v1',
    mt_rm: url.searchParams.get('mt') || 'mtl_1',
  }

  return { ropts }
}) satisfies PageLoad
