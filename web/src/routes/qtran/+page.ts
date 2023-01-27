export async function load({ url }) {
  const dname = url.searchParams.get('dname') || 'combine'
  const input = url.searchParams.get('input')
  return { dname, input, _path: 'qtran' }
}
