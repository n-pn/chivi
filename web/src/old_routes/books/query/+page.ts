import { wrap_get } from '$lib/api_call'

export async function load({ fetch, url }) {
  const pg = +url.searchParams.get('pg') || 1
  const type = url.searchParams.get('t') || 'btitle'
  const input = url.searchParams.get('q')

  if (!input) return { input, type }

  const qs = input.replace(/\+|-/g, ' ')
  const api_url = `/api/books?order=weight&lm=8&pg=${pg}&${type}=${qs}`

  const topbar = { search: input }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return await wrap_get(fetch, api_url, null, { input, type }, { topbar })
}
