<script context="module" lang="ts">
  import { seed_url, to_pgidx } from '$utils/route_utils'

  export async function load({ stuff }) {
    const { nvinfo, ubmemo } = stuff
    const { sname, chidx } = ubmemo
    const redirect = seed_url(nvinfo.bslug, sname, to_pgidx(chidx))
    return { status: 303, redirect: redirect }
  }
</script>
