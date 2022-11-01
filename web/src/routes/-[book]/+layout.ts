import { redirect } from '@sveltejs/kit'
import { get_nvbook } from '$lib/api'

export async function load({ params, url, fetch }) {
  const bslug = params.book

  try {
    return await get_nvbook(bslug, fetch)
  } catch (error) {
    const location = error.location
    if (!location) throw error

    const decode = decodeURI(location)
    throw redirect(error.status, encodeURI(url.pathname.replace(bslug, decode)))
  }
}
