import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const { ustem, rdata } = await parent()

  const ropts = get_ropts(ustem, rdata, url.searchParams)

  return { rdata, ropts }
}) satisfies PageLoad

function get_ropts(ustem: CV.Upstem, { fpath }, params: URLSearchParams) {
  const wn_id = ustem.wn_id

  return {
    fpath,
    pdict: ustem.wndic && wn_id ? `book/${wn_id}` : `up/${ustem.id}`,
    wn_id: wn_id || 0,
    rtype: params.get('rm') || 'qt',
    qt_rm: params.get('qt') || 'qt_v1',
    mt_rm: params.get('mt') || 'mtl_1',
  }
}
