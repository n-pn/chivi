import { error, redirect } from '@sveltejs/kit'

export const load = async ({ fetch, url, params }) => {
  const bslug = params.book.split('/', 2)[0]

  const res = await fetch(`/_db/books/find/${bslug}`)
  if (!res.ok) throw error(500, await res.text())

  const data = await res.json()
  if (!data.found) throw redirect(302, '/books')

  let location = url.pathname.replace('/-' + bslug, '/wn/' + data.found)
  if (url.search) location += url.search

  throw redirect(301, location)
}
