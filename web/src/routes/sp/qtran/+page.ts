import { home_nav, nav_link } from '$utils/header_util'

export async function load({ url }) {
  return {
    wn_id: url.searchParams.get('wn_id') || 0,
    input: url.searchParams.get('input'),
    _title: 'Dịch nhanh',
    _mdesc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
    _meta: {
      left_nav: [home_nav('ts'), nav_link('/sp/qtran', 'Dịch nhanh', 'bolt')],
    },
  }
}
