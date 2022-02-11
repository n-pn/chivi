import { browser } from '$app/env'
import { writable } from 'svelte/store'

export function create_config_store(name, data) {
  if (browser) {
    const stored = localStorage.getItem(name)
    if (stored) data = JSON.parse(stored)
  }

  const store = {
    ...writable(data),
    put(key, val_or_fn) {
      store.update((x) => {
        x[key] = typeof val_or_fn == 'function' ? val_or_fn(x[key]) : val_or_fn
        return x
      })
    },
    toggle: (key) => store.put(key, (x) => !x),
    set_render: (val) => store.put('render', (old) => (old == val ? 0 : val)),
  }

  store.subscribe((val) => {
    if (browser) localStorage.setItem(name, JSON.stringify(val))
  })

  return store
}
