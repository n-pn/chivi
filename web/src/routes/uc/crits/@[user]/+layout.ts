import type { LayoutData } from './$types'

export const load = (async ({ parent, params: { user } }) => {
  const { _navs } = await parent()

  return {
    _curr: { text: user },
    _navs: [
      ..._navs,
      { href: `@${user}`, text: `Đánh giá của @${user}`, icon: 'at', kind: 'title' },
    ],
  }
}) satisfies LayoutData
