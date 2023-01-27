import { redirect } from '@sveltejs/kit'

export async function load({ url }) {
  throw redirect(304, '/ys' + url.pathname + url.search)
}
