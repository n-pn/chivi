export async function load({ fetch, params: { board } }) {
  const api_url = `/api/boards/` + board
  const api_res = await fetch(api_url)
  const { props } = await api_res.json()
  return props
}
