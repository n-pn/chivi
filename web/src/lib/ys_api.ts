export async function get_repls(crit_id: string) {
  const res = await fetch(`/_ys/crits/${crit_id}/repls`)
  if (res.ok) return await res.json()
  console.error(await res.text())
  return []
}

export async function get_crits(
  params = new URLSearchParams(),
  extra: Record<string, string | number> = {},
  fetch = globalThis.fetch
) {
  if (!(params instanceof URLSearchParams)) {
    params = new URLSearchParams(params)
  }

  if (typeof extra == 'object') {
    for (let key in extra) {
      const val = extra[key]
      if (val) params.append(key, val.toString())
    }
  }

  const url = `/_ys/crits?` + params.toString()
  const res = await fetch(url)
  return await res.json()
}

export async function view_crit(crit_id: string, fetch = globalThis.fetch) {
  const url = `/_ys/crits/${crit_id}`
  const res = await fetch(url)
  return await res.json()
}
