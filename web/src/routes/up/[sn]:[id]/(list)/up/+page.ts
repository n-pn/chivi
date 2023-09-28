import type { PageLoad } from './$types'
import { nav_link } from '$utils/header_util'

export const load = (async ({ url, parent }) => {
  const { ustem, sroot } = await parent()
  const start = +url.searchParams.get('start') || ustem.chap_count + 1
  const chdiv = url.searchParams.get('chdiv')

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link(sroot, ustem.vname, 'list', { show: 'pl', kind: 'title' }),
      nav_link('up', 'Thêm/sửa chương', 'file-plus', { show: 'pm' }),
    ],
    show_config: true,
  }

  const _title = 'Thêm/sửa chương truyện ' + ustem.vname
  return { start, chdiv, _meta, _title, ontab: 'up' }
}) satisfies PageLoad
