import { browser } from '$app/environment'

export async function local_get<T>(
  ckey: string,
  reset: boolean = false,
  fetcher: () => Promise<T>
) {
  if (!reset && browser) {
    const cached = sessionStorage.getItem(ckey)
    if (cached) return JSON.parse(cached) as T
  }

  const new_data = (await fetcher()) as T
  if (!new_data['error'] && browser) {
    sessionStorage.setItem(ckey, JSON.stringify(new_data))
  }

  return new_data
}

export function local_del<T>(ckey: string) {
  if (!browser) return null
  return sessionStorage.removeItem(ckey)
}
