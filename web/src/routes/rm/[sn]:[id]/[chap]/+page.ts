import { _pgidx } from '$lib/kit_path'
import type { PageLoad } from './$types'

export const load = (async ({ url, parent }) => {
  const { rstem, rdata } = await parent()
  const ropts = get_ropts(rstem, rdata, url)
  return { rdata, ropts }
}) satisfies PageLoad

function get_ropts(rstem: CV.Rmstem, { fpath }, { searchParams }) {
  return {
    fpath,
    pdict: rstem.wn_id ? `book/${rstem.wn_id}` : 'combine',
    wn_id: rstem.wn_id || 0,
    rtype: searchParams.get('rm') || 'qt',
    qt_rm: searchParams.get('qt') || 'qt_v1',
    mt_rm: searchParams.get('mt') || 'mtl_1',
  }
}
