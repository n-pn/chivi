import { writable } from 'svelte/store'

export const user = writable({ uname: 'Khách', power: -1 })

export const header = writable({ page: 'index', query: '' })
export const layout = writable({ shift: false, clear: false })

// export const search_page = writable(false)
// export const search_term = writable('')
