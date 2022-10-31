import { status_types, status_names } from '$lib/constants'
import { wrap_get } from '$lib/api_call'

export async function load({ url, params, fetch }) {
  const [uname, bmark = 'reading'] = params.uname.split('/')
  const page = +url.searchParams.get('pg') || 1

  const api_url = `/api/books?pg=${page}&lm=24&order=update&uname=${uname}&bmark=${bmark}`

  const topbar = {
    left: [[`Tủ truyện của [${uname}]`, 'notebook', { href: url.pathname }]],
  }
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return await wrap_get(fetch, api_url, null, { uname, bmark }, { topbar })
}
