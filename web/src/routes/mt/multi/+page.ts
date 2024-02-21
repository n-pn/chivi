import type { PageLoad } from './$types'

export const load = (async ({ parent, url: { searchParams } }) => {
  const { _navs } = await parent()

  return {
    input: (searchParams.get('zh') || '').trim(),
    pdict: searchParams.get('pd') || 'combine',
    mtype: searchParams.get('mt') || 'mtl_2',
    ontab: 'multi',
    _navs: [..._navs, { text: 'Dịch tổng hợp', icon: 'language', href: '/mt/multi' }],
  }
}) satisfies PageLoad
