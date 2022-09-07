export async function list_repls(crit_id: string) {
  const res = await fetch(`/_ys/crits/${crit_id}/repls`)
  if (res.ok) return await res.json()

  console.error(await res.text())
  return []
}
