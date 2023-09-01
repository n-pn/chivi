import { error, redirect } from '@sveltejs/kit'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url, params }) => {
  const cols = params.any.split('/')
  const root = cols[0]

  if (root == 'uc') throw redirect(304, replace_url(url, '/uc', '/wn/crits'))
  if (root == 'ul') throw redirect(304, replace_url(url, '/ul', '/wn/lists'))
  if (root == 'ys') throw redirect(304, replace_url(url, '/ys', '/wn'))

  if (root == 'notes') throw redirect(301, replace_url(url, root, 'hd'))
  if (root == 'guide') throw redirect(301, replace_url(url, root, 'hd'))

  if (root.startsWith('-'))
    throw await load_old_book(root.substring(1), fetch, url)

  if (root == 'books') {
    if (!cols[1].startsWith('@'))
      throw redirect(302, replace_url('books', 'wn'))
    const user = cols[1]
    throw redirect(301, replace_url(`books/${user}`, `${user}/books`))
  }

  throw error(404, 'Đường dẫn không tồn tại')
}) satisfies PageLoad

const replace_url = (url: URL, old_path: string, new_path: String) => {
  return url.pathname.replace(old_path, new_path + url.search)
}

const load_old_book = async (bslug: string, fetch: CV.Fetch, url: URL) => {
  const res = await fetch(`/_db/books/find/${bslug}`)
  if (!res.ok) return error(500, await res.text())

  const data = await res.json()
  if (!data.found) return redirect(302, '/wn')

  let location = url.pathname.replace('/-' + bslug, '/wn/' + data.found)
  if (url.search) location += url.search

  return redirect(301, location)
}
