import type { PageLoad } from './$types'

export const load = (async ({ url }) => {
  const input = (url.searchParams.get('zh') || '').trim()

  const _meta: App.PageMeta = {
    left_nav: [{ text: 'Dịch nhanh', icon: 'bolt', href: url.pathname }],
  }

  return { input, _meta, _title: 'Tổng hợp lỗi máy dịch', ontab: 'sent' }
}) satisfies PageLoad
