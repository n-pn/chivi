import { nvinfo_bar } from '$utils/topbar_utils'
import { suggest_read } from '$utils/ubmemo_utils'

export async function load({ parent }) {
  const { nvinfo, ubmemo } = await parent()

  const _meta = {
    title: 'Thêm nguồn',
    left_nav: [nvinfo_bar(nvinfo)],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  }

  return { _meta, nv_tab: 'chaps' }
}
