<!-- <script lang="ts">
  import { crumbs } from '$gui/global/Bcrumb.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, crepo, rdata, ropts, sroot, rmemo } = data)

  import Reader from '$gui/shared/reader/Reader.svelte'
  import Rdfoot from '$gui/shared/reader/Rdfoot.svelte'

  $: $crumbs = [
    { text: 'Sưu tầm cá nhân', href: `/up` },
    { text: ustem.vname, href: sroot },
    { text: rdata.chdiv || 'Chính văn' },
    { text: rdata.title },
  ]
</script>

<Reader {crepo} {ropts} {rdata} />
<Rdfoot {crepo} {ropts} {rdata} {rmemo} /> -->
