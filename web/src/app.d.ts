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
  }

  interface Stuff {
    nvinfo: CV.Nvinfo
    ubmemo: CV.Ubmemo
    chseed?: JSON
  }
}
