type BookEdit = { bintro: string; genres: string; bcover: string }

import type { PageLoad } from './$types'
export const load: PageLoad = async ({ parent, fetch }) => {
  const { nvinfo } = await parent()

  const api_url = `/_db/v2/books/${nvinfo.id}/+edit`
  const api_res = await fetch(api_url)

  const { bintro, genres, bcover }: BookEdit = await api_res.json()

  const nvinfo_form = { ...nvinfo, bintro, genres, bcover }

  return { nvinfo_form }
}
