import type { Writable } from 'svelte/store'
import { writable } from 'svelte/store'

interface AppBar {
  page?: string
  left?: Array<Array<string | null>>
  right?: Array<Array<any>>
  query?: string
  cvmtl?: boolean
}

export const appbar: Writable<AppBar> = writable({})
export const toleft = writable(false)

let prevScrollTop = 0

export const scroll = {
  ...writable(0),
  on_scroll: () => {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    scroll.set(scrollTop - prevScrollTop)
    prevScrollTop = scrollTop <= 0 ? 0 : scrollTop
  },
}
