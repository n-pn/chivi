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

  interface TopbarItem {
    'text'?: string
    'icon'?: string
    'href'?: string
    'data-show'?: string
    'data-kind'?: string
  }

  interface PageData {
    nvinfo: CV.Nvinfo
    ubmemo: CV.Ubmemo
    nslist: CV.Nslist

    nv_tab: 'index' | 'board' | 'crits' | 'chaps'

    _user: Sesssion

    _meta?: {
      title: string
      desc?: string
    }

    _head_left?: TopbarItem[]
    _head_right?: TopbarItem[]
    _head_config?: boolean
  }
}
