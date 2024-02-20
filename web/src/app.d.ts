/// <reference types="@sveltejs/kit" />

// See https://kit.svelte.dev/docs/typescript
// for information about these interfaces
declare namespace App {
  interface CurrentUser {
    vu_id: number
    uname: string

    privi: number
    until: number

    vcoin: number

    quota: number

    unread_notif: number
  }

  interface Locals {
    _user: CurrentUser
  }

  interface Platform {}

  interface PageNavi {
    text: string
    href: string
    icon?: string
    show?: string
    kind?: string
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
    _alts?: PageNavi[]
    _curr?: PageNavi
    _prev?: PageNavi
  }
}
