import { writable, get } from 'svelte/store'

export const ubmemos = {
  ...writable(new Map<number, CV.Ubmemo>()),
  async load(id: number) {
    return await fetch(`/api/_self/books/${id}`).then((r) => r.json())
  },
  get: (id: number) => get(ubmemos).get(id),
  put(id: number, memo: CV.Ubmemo) {
    ubmemos.update((x) => {
      x.set(id, memo)
      return x
    })
  },
}
