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

  interface PageNavi {
    text: string
    href: string

    hd_icon?: string
    hd_text?: string
    hd_show?: string
    hd_kind?: string
  }

  interface PageData {
    _user?: CurrentUser

    _meta?: {
      title?: string
      image?: string
      mdesc?: string
      ogurl?: string
    }

    _navs?: PageNavi[]
  }
}
