/// <reference types="@sveltejs/kit" />

// See https://kit.svelte.dev/docs/typescript
// for information about these interfaces
declare namespace App {
  interface CurrentUser {
    uname: string
    privi: number

    wtheme: string

    vcoin_avail: number
    vcoin_total: number

    privi_1_until: number
    privi_2_until: number
    privi_3_until: number
  }

  interface Locals {
    _user: CurrentUser
  }

  interface Platform {}

  interface HeadItem {
    'text'?: string
    'icon'?: string
    'href'?: string
    'disable'?: boolean
    'data-kbd'?: string
    'data-show'?: string
    'data-kind'?: string
  }

  interface PageMeta {
    title: string
    desc?: string

    left_nav?: HeadItem[]
    right_nav?: HeadItem[]
    show_config?: boolean
  }

  interface PageData {
    nvinfo?: CV.Nvinfo
    ubmemo?: CV.Ubmemo
    nslist?: CV.Nslist

    _user?: CurrentUser
    _meta?: PageMeta
  }
}
