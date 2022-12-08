import { redirect, error } from '@sveltejs/kit'

export async function load({ url, params: { slug } }) {
  if (slug.match(/^(crits|lists)/))
    throw redirect(300, '/ys' + url.pathname + url.search)

  if (slug.startsWith('notes'))
    throw redirect(301, slug.replace('notes', '/guide'))

  throw error(404, `${slug} not found!`)
}
