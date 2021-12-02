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

export function create_layers_store(data = []) {
  const { subscribe, update } = writable(data)

  return {
    subscribe,
    add: (layer) => update((x) => [layer, ...x]),
    remove: (layer) => update((x) => x.filter((i) => i != layer)),
    toggle(active, layer) {
      active ? this.add(layer) : this.remove(layer)
    },
  }
}

export function create_input() {
  const input = {
    ...writable({ ztext: '', lower: 0, upper: 1 }),
    put(data) {
      if (Array.isArray(data)) {
        const [ztext, lower, upper] = data
        input.set({ ztext, lower, upper })
      } else if (typeof data === 'string') {
        input.set({ ztext: data, lower: 0, upper: data.length })
      } else {
        input.set(data)
      }
    },
    move_lower(value = 1) {
      input.update((x) => {
        x.lower += value
        if (value > 0 && x.upper <= x.lower) x.upper = x.lower + 1
        return x
      })
    },
    move_upper(value = 1) {
      input.update((x) => {
        x.upper += value
        if (value < 0 && x.lower >= x.upper) x.lower = x.upper - 1
        return x
      })
    },
  }

  return input
}
