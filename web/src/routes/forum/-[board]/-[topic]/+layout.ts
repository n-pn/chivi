import type { LayoutLoad } from './$types'

export const load: LayoutLoad = async ({ fetch, params: { topic } }) => {
  const frags = topic.split('-')
  const path = `/_db/topics/${frags.pop()}`
  const cvpost = await fetch(path).then((r) => r.json())
  return { cvpost }
}
