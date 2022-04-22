import { writable } from 'svelte/store'

export const appbar = writable({
  lefts: [],
  rights: [],
  config: false,
  search: '',
})

export const toleft = writable(false)

let prevScrollTop = 0

export const scroll = {
  ...writable(0),
  update() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    scroll.set(scrollTop - prevScrollTop)
    prevScrollTop = scrollTop <= 0 ? 0 : scrollTop
  },
  reset() {
    prevScrollTop = 0
    scroll.set(0)
  },
}

export const usercp = {
  ...writable({ actived: false, tab: 0 }),
  show: (tab = 0) => usercp.set({ actived: true, tab }),
  hide: () => usercp.set({ actived: false, tab: 0 }),
  change_tab: (tab: number) => usercp.update((x) => ({ ...x, tab })),
}
