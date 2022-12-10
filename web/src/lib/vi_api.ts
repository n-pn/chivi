import { error } from '@sveltejs/kit'

export async function all_lists(search: string = '', fetch = globalThis.fetch) {
  const url = `/api/lists?${search}`
  const res = await fetch(url)
  return await res.json()
}

export async function get_crits(search: string = '', fetch = globalThis.fetch) {
  const url = `/api/crits?${search}`
  const res = await fetch(url)
  return (await res.json()) as CV.VicritList
}

export async function crit_info(crit_id: number, fetch = globalThis.fetch) {
  const url = `/api/crits/${crit_id}`
  const res = await fetch(url)

  if (!res.ok) throw error(res.status, await res.text())
  return (await res.json()) as CV.Vicrit
}

export async function crit_edit(crit_id: number, fetch = globalThis.fetch) {
  const url = `/api/crits/${crit_id}/edit`
  const res = await fetch(url)

  if (!res.ok) if (!res.ok) throw error(res.status, await res.text())
  return (await res.json()) as CV.VicritForm
}

export async function crit_repls(crit_id: number) {
  const res = await fetch(`/api/repls?crit=${crit_id}&sort=ctime`)
  if (res.ok) return await res.json()
  console.error(await res.text())
  return []
}
