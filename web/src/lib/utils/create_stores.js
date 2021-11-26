import { browser } from '$app/env'
import { writable } from 'svelte/store'

export function create_config_store(name, data) {
  if (browser) {
    const stored = localStorage.getItem(name)
    if (stored) data = JSON.parse(stored)
  }

  const { subscribe, set, update } = writable(data)

  return {
    subscribe,
    store(data) {
      if (browser) {
        localStorage.setItem(name, JSON.stringify(data))
      }
    },
    set(data) {
      set(data)
      this.store(data)
    },
    update(func) {
      update((data) => {
        data = func(data)
        this.store(data)
        return data
      })
    },
    put(key, val) {
      this.update((x) => ({ ...x, [key]: val }))
    },
  }
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
  }

  return input
}
