import type { LayoutLoad } from './$types'

export const load = (async ({ parent }) => {
  const { _navs } = await parent()
  return {
    _navs: [
      ..._navs,
      {
        href: '/uc/crits',
        text: 'Đánh giá truyện chữ',
        hd_icon: 'stars',
        hd_kind: 'title',
      },
    ],
  }
}) satisfies LayoutLoad
