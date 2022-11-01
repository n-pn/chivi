throw new Error("@migration task: Migrate the load function input (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
export async function load({ stuff, fetch, url }) {
  const { nvinfo } = stuff

  const pg = +url.searchParams.get('pg') || 1
  const lb = url.searchParams.get('lb')

  let api_url = `/api/topics?dboard=${nvinfo.id}&pg=${pg}&lm=10`
  if (lb) api_url += `&labels=${lb}`

  const res = await fetch(api_url)
  throw new Error("@migration task: Migrate this return statement (https://github.com/sveltejs/kit/discussions/5774#discussioncomment-3292693)");
  return await res.json()
}
