/// <reference types="@sveltejs/kit" />

// See https://kit.svelte.dev/docs/typescript
// for information about these interfaces
declare namespace App {
  interface CurrentUser {
    vu_id: number
    uname: string
    privi: number

    vcoin: number
    until: number

    point_today: number
    point_limit: number

    unread_notif: number
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
    url?: string
    image?: string

    left_nav?: HeadItem[]
    right_nav?: HeadItem[]
    show_config?: boolean
  }

  interface PageData {
    nvinfo?: CV.Nvinfo
    ubmemo?: CV.Ubmemo

    _user?: CurrentUser
    _meta?: PageMeta
  }
}
