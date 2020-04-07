import { writable } from 'svelte/store'

export const segment = writable('index')

export const lookup_active = writable(false)
export const lookup_pinned = writable(true)

export const lookup_line = writable([])
export const lookup_from = writable(0)
export const lookup_udic = writable(null)
