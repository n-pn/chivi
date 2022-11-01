const _meta: App.PageMeta = {
  title: 'Dịch nhanh',
  desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
  left_nav: [{ text: 'Dịch nhanh', icon: 'bolt', href: '/qtran' }],
}

export async function load({ url }) {
  const dname = url.searchParams.get('dname') || 'combine'
  const input = url.searchParams.get('input')
  return { dname, input, _meta }
}
