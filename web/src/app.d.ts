/// <reference types="@sveltejs/kit" />

// See https://kit.svelte.dev/docs/typescript
// for information about these interfaces
declare namespace App {
  interface Locals {}
  interface Platform {}

  interface Session {
    uname: string
    privi: number

    wtheme: string

    vcoin_avail: number
    vcoin_total: number

    privi_1_until: number
    privi_2_until: number
    privi_3_until: number
  }

  type BarItem = [string, string | undefined, Record<string, any> | undefined]

  interface Topbar {
    left: BarItem[] = []
    right: BarItem[] = []
    config?: boolean = false
    search?: string = ''
  }

  import type { API } from '$lib/api'

  interface Stuff {
    api: API
    nvinfo: CV.Nvinfo
    ubmemo: CV.Ubmemo
    nslist: CV.Chseed[]

    nv_tab: 'index' | 'board' | 'crits' | 'chaps'
    topbar: Topbar
  }
}
