import { writable, get } from 'svelte/store'

export const ubmemos = {
  ...writable(new Map<number, CV.Ubmemo>()),
  async load(id: number) {
    const api_url = `/api/_self/books/${id}`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()
    return payload.props
  },
  get: (id: number) => get(ubmemos).get(id),
  put(id: number, memo: CV.Ubmemo) {
    ubmemos.update((x) => {
      x.set(id, memo)
      return x
    })
  },
}
