import type { PageLoad } from './$types'

export const load = (async ({ url }) => {
  const cpart = +url.searchParams.get('part') || 1
  const [rtype, rmode] = get_type_and_mode(url.searchParams)

  return { cpart, rtype, rmode }
}) satisfies PageLoad

function get_type_and_mode(search: URLSearchParams) {
  let rtype = search.get('type')

  switch (rtype) {
    case 'qt':
      return [rtype, 'mt_v1']

    case 'tl':
      return [rtype, 'basic']

    case 'cf':
      return [rtype, search.get('mode')]

    default:
      return ['mt', search.get('mode') || 'avail']
  }
}
