export async function load({ fetch, params: { topic } }) {
  const frags = topic.split('-')
  const topic_id = frags[frags.length - 1]

  const api_url = `/api/topics/${topic_id}`
  const api_res = await fetch(api_url)
  const { props } = await api_res.json()

  return props
}
