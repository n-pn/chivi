export async function load({ url }) {
  const dname = url.searchParams.get('dname') || 'combine'
  const input = url.searchParams.get('input')

  const _meta = {
    title: 'Dịch nhanh',
    desc: 'Dịch nhanh từ tiếng Trung sang tiếng Việt',
  }
  const _head_left = [{ text: 'Dịch nhanh', icon: 'bolt', href: '/qtran' }]

  return { dname, input, _meta, _head_left }
}
