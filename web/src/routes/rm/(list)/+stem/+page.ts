import type { PageLoad } from './$types'

const _navs = [
  {
    href: '/rm',
    text: 'Nguồn nhúng',
    hd_icon: 'world',
    hd_show: 'pl',
  },
  {
    href: '/rm/+stem',
    text: 'Thêm mới',
    hd_icon: 'file-plus',
    hd_kind: 'title',
  },
]

export const load = (() => {
  return {
    ontab: '+new',
    _navs,
    _meta: { title: 'Thêm nguồn nhúng mới' },
  }
}) satisfies PageLoad
