import type { LayoutData } from './$types'

export const load = (async ({ parent, params: { user } }) => {
  const { _navs } = await parent()

  return {
    _navs: [
      ..._navs,
      {
        href: `@${user}`,
        text: `Đánh giá của @${user}`,
        hd_icon: 'at',
        hd_text: user,
        hd_kind: 'title',
      },
    ],
  }
}) satisfies LayoutData
