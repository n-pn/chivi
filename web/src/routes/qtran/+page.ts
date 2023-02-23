import { home_nav, nav_link } from '$gui/global/header_util'

const _meta: App.PageMeta = {
  title: 'Dịch nhanh',
  desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
  left_nav: [home_nav('tm'), nav_link('/qtran', 'Dịch nhanh', 'bolt')],
}

export async function load({ url }) {
  return {
    dname: url.searchParams.get('dname') || 'combine',
    input: url.searchParams.get('input'),
    _meta,
  }
}
