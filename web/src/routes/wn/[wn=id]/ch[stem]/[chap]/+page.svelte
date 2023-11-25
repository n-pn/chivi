<script lang="ts">
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, wstem, crepo, rdata, ropts, rmemo } = data)

  import Reader from '$gui/shared/reader/Reader.svelte'
  import Rdfoot from '$gui/shared/reader/Rdfoot.svelte'

  $: $crumbs = [
    { text: nvinfo.vtitle, href: `/wn/${nvinfo.bslug}` },
    { text: `[${wstem.sname}]`, href: crepo.rpath },
    { text: rdata.chdiv || 'Chính văn' },
    { text: rdata.title },
  ]
</script>

<Reader {crepo} {ropts} {rdata} />
<Rdfoot {crepo} {ropts} {rdata} {rmemo} />
