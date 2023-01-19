import type { LoadEvent } from '@sveltejs/kit'

export const load = async ({ fetch, params: { board } }: LoadEvent) => {
  return fetch(`/_db/boards/${board}`).then((r) => r.json())
}
