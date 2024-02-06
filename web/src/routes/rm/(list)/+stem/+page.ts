import type { PageLoad } from './$types'

const _navs = [
  {
    href: '/rm',
    text: 'Nguồn nhúng',
    icon: 'world',
    show: 'pl',
  },
  {
    href: '/rm/+stem',
    text: 'Thêm mới',
    icon: 'file-plus',
    kind: 'title',
  },
]

export const load = (() => {
  return {
    ontab: '+new',
    _navs,
    _meta: { title: 'Thêm nguồn nhúng mới' },
  }
}) satisfies PageLoad
