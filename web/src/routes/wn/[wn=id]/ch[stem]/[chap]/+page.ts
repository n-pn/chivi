import { _pgidx } from '$lib/kit_path'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent }) => {
  const { nvinfo, rdata } = await parent()
  const ropts = get_ropts(nvinfo.id, rdata, url.searchParams)

  // const _board = `ch:${book}:${chap}:${sname}`

  return { ropts }
}) satisfies PageLoad

function get_ropts(wn_id: number, { fpath }, params: URLSearchParams) {
  return {
    fpath,
    pdict: `book/${wn_id}`,
    wn_id: wn_id,
    rmode: params.get('rm') || 'qt',
    qt_rm: params.get('qt') || 'qt_v1',
    mt_rm: params.get('mt') || 'mtl_1',
  }
}
