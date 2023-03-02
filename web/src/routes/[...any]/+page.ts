import { error, redirect } from '@sveltejs/kit'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params }) => {
  const cols = params.any.split('/')
  const root = cols[0]

  if (root.startsWith('-')) {
    throw await load_old_book(root.substring(1), fetch, url)
  }

  if (root == 'crits' || root == 'lists') {
    throw redirect(304, '/ys' + url.pathname + url.search)
  }

  if (root == 'books') {
    if (!cols[1].startsWith('@')) {
      redirect(302, url.pathname.replace('books', 'wn') + url.search)
    }

    const user = cols[1]
    redirect(301, url.pathname.replace(`books/${user}`, `${user}/books`))
  }

  throw error(404, 'Đường dẫn không tồn tại')
}) satisfies PageLoad

const load_old_book = async (bslug: string, fetch: CV.Fetch, url: URL) => {
  const res = await fetch(`/_db/books/find/${bslug}`)
  if (!res.ok) return error(500, await res.text())

  const data = await res.json()
  if (!data.found) return redirect(302, '/wn')

  let location = url.pathname.replace('/-' + bslug, '/wn/' + data.found)
  if (url.search) location += url.search

  return redirect(301, location)
}
