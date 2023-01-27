export async function load({ url }) {
  return {
    dname: url.searchParams.get('dname') || 'combine',
    input: url.searchParams.get('input'),
  }
}
