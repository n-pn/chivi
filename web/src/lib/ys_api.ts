const GET = {
  ys_lists: (_opts?: any) => `/_ys/lists`,
  ys_crits: (_opts?: any) => `/_ys/crits`,
  ys_repls: ({ crit_id }) => `/_ys/crits/${crit_id}/repls`,
}

export async function get_repls(crit_id: string) {
  const res = await fetch(`/_ys/crits/${crit_id}/repls`)
  if (res.ok) return await res.json()
  console.error(await res.text())
  return []
}

export async function get_crits(search: string, fetch = globalThis.fetch) {
  const url = `/_ys/crits?${search}`
  const res = await fetch(url)
  return await res.json()
}

export async function view_crit(crit_id: string, fetch = globalThis.fetch) {
  const url = `/_ys/crits/${crit_id}`
  const res = await fetch(url)
  return await res.json()
}

export async function get_lists(params: string, fetch = globalThis.fetch) {
  const url = `/_ys/lists?${params}`
  const res = await fetch(url)
  if (res.ok) return await res.json()
  console.error(await res.text())
  return []
}
