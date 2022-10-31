import { redirect, error } from '@sveltejs/kit'

export async function load({ params: { slug } }) {
  if (slug.startsWith('notes')) {
    throw redirect(301, slug.replace('notes', '/guide'))
  } else {
    throw error(404, `${slug} not found!`)
  }
}
