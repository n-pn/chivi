throw new Error("@migration task: Check if you need to migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ fetch, params: { topic } }) {
  const frags = topic.split('-')
  const topic_id = frags[frags.length - 1]

  const api_url = `/api/topics/${topic_id}`
  const api_res = await fetch(api_url)
  const payload = await api_res.json()

  payload.stuff = payload.props
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return payload
}
