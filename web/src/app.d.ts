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

  interface Stuff {
    nvinfo: CV.Nvinfo
    ubmemo: CV.Ubmemo
    chseed: CV.Chseed[]
  }
}
