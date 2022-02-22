import { writable } from 'svelte/store'

type DialogStore = { actived: boolean; [x: string]: any }

export function dialog_store(init: DialogStore = { actived: false }) {
  const store = {
    ...writable(init),
    show: () => store.update((x) => ({ ...x, actived: true })),
    hide: () => store.update((x) => ({ ...x, actived: false })),
    toggle: () => store.update((x) => ({ ...x, actived: !x.actived })),
  }

  return store
}
