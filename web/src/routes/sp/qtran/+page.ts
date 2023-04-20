import { home_nav, nav_link } from '$utils/header_util'

const _meta: App.PageMeta = {
  title: 'Dịch nhanh',
  desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
  left_nav: [home_nav('tm'), nav_link('/sp/qtran', 'Dịch nhanh', 'bolt')],
}

export async function load({ url }) {
  return {
    wn_id: url.searchParams.get('wn_id') || 0,
    input: url.searchParams.get('input'),
    _meta,
  }
}
