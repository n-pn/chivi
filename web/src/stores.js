import { writable } from 'svelte/store'

export const user = writable({ uname: 'Khách', power: -1 })

export const layout_clear = writable(false)
export const layout_shift = writable(false)

// export const search_page = writable(false)
// export const search_term = writable('')
