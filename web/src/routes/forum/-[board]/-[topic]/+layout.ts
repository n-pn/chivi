import { api_path } from '$lib/api_call'
import type { LayoutLoad } from './$types'

export const load: LayoutLoad = async ({ fetch, params: { topic } }) => {
  const frags = topic.split('-')
  const path = api_path('dtopics.show', frags[frags.length - 1])
  return fetch(path).then((r) => r.json())
}
