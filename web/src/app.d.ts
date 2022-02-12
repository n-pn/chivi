/// <reference types="@sveltejs/kit" />

import type from './types/models'

// See https://kit.svelte.dev/docs/typescript
// for information about these interfaces
declare namespace App {
  interface Locals {}
  interface Platform {}

  interface Session {
    uname: string
    privi: number
    wtheme: string
  }

  interface Stuff {
    nvinfo: Nvinfo
    ubmemo?: JSON
    chseed?: JSON
  }
}
