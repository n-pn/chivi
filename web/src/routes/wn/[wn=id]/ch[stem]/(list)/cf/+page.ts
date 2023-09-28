import { seed_path } from '$lib/kit_path.js'
import { nav_link } from '$utils/header_util'

export const load = async ({ parent }) => {
  const { nvinfo, curr_seed } = await parent()
  const seed_href = seed_path(nvinfo.bslug, curr_seed.sname)

  const _meta = {
    left_nav: [
      nav_link(seed_href, nvinfo.vtitle, 'list', {
        kind: 'title',
        show: 'pl',
      }),
      nav_link('cf', 'Cài đặt', 'settings', { show: 'pm' }),
    ],
  }

  return { ontab: 'cf', _meta, _title: 'Cài đặt nguồn truyện ' + nvinfo.vtitle }
}
