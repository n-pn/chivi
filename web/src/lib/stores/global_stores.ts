import type { Writable } from 'svelte/store'
import { writable } from 'svelte/store'

interface AppBar {
  left?: Array<Array<string | null>>
  right?: Array<Array<any>>
  query?: string
  cvmtl?: boolean
}

export const appbar: Writable<AppBar> = writable({})
export const scroll = writable(0)
export const toleft = writable(false)
