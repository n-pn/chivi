import { writable } from 'svelte/store'

export const auth = writable({ uname: 'Khách', power: -1 })

// export const search_page = writable(false)
// export const search_term = writable('')
