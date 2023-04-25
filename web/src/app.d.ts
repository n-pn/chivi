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
    url?: string
    left_nav?: HeadItem[]
    right_nav?: HeadItem[]
    show_config?: boolean
  }

  interface PageData {
    _user?: CurrentUser
    _meta?: PageMeta

    _title?: string
    _image?: string
    _mdesc?: string

    _board?: string
    _mtcfg?: boolean
  }
}
