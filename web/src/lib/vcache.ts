import { browser } from '$app/environment'

export async function local_get<T>(
  c_key: string,
  reuse: boolean = true,
  fetch: () => Promise<T>
) {
  if (!browser) return (await fetch()) as T

  if (reuse) {
    const prev = localStorage.getItem(c_key)
    if (prev) return JSON.parse(prev) as T
  }

  const data = (await fetch()) as T

  if (!data['error']) {
    try {
      localStorage.setItem(c_key, JSON.stringify(data))
    } catch (ex) {
      console.log(ex.message)
      localStorage.clear()
    }
  }

  return data
}

export function local_del(c_key: string) {
  if (!browser) return null
  return localStorage.removeItem(c_key)
}
