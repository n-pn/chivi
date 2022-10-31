import { wrap_get } from '$lib/api_call'

throw new Error("@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ url, fetch, params: { genre } }) {
  const api_url = new URL(url)
  api_url.pathname = '/api/books'
  api_url.searchParams.set('lm', '24')
  api_url.searchParams.set('genre', genre)

  const extra = { genres: genre.split('+') }
  const topbar = { left: [['Thể loại', 'folder', { href: url.pathname }]] }

  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return await wrap_get(fetch, api_url.toString(), null, extra, { topbar })
}
