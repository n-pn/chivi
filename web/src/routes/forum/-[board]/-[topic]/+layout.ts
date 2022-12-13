import { api_path } from '$lib/api_call'

export async function load({ fetch, params: { topic } }) {
  const frags = topic.split('-')
  const path = api_path('dtopics.show', frags[frags.length - 1])
  return await fetch(path).then((r: Response) => r.json())
}
