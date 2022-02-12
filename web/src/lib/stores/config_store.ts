import { writable } from 'svelte/store'

export interface Config {
  wtheme: string
  ftsize: number
  ftface: number
  textlh: number
  render: number
  showzh: boolean
}

const storage_key = '_pref'

function load_store(): Config {
  if (globalThis.localStorage) {
    const stored = localStorage.getItem(storage_key)
    if (stored) return JSON.parse(stored)
  }

  return {
    wtheme: '',
    ftsize: 3,
    ftface: 1,
    textlh: 150,
    render: 0,
    showzh: false,
  }
}

export const config = {
  ...writable(load_store()),
  put(key: string, val: any) {
    config.update((x: Config) => {
      x[key] = val
      return x
    })
  },
  put_fn(key: string, fn: (x: any) => any) {
    config.update((x: Config) => {
      x[key] = fn(x[key])
      return x
    })
  },
  toggle: (key: string) => config.put_fn(key, (x) => !x),
  set_render: (val: number) => {
    config.update((x: Config) => {
      const old = x.render
      x.render = val == old ? 0 : val
      return x
    })
  },
}

config.subscribe((config: Config) => {
  if (globalThis.localStorage) {
    localStorage.setItem(storage_key, JSON.stringify(config))
  }
})
