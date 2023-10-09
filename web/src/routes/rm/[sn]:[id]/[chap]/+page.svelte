<script lang="ts">
  import { chap_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Crumb from '$gui/molds/Crumb.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ rstem, rdata, ropts, sroot } = data)

  $: ch_no = rdata.ch_no
  // $: total = rstem.chmax || rstem.chap_count

  $: prev_path = rdata._prev ? chap_path(sroot, rdata._prev, ropts) : sroot
  $: next_path = rdata._next ? chap_path(sroot, rdata._next, ropts) : sroot

  import Reader from '$gui/shared/reader/Reader.svelte'

  $: crumb = [
    { text: 'Nguồn nhúng tự động', href: `/rm` },
    { text: rstem.btitle_vi, href: sroot },
    { text: rdata.chdiv || 'Chính văn' },
    { text: rdata.title },
  ]

  $: cstem = {
    stype: 'rm',
    sroot,

    sname: rstem.sname,
    sn_id: rstem.sn_id,

    chmax: rstem.chap_count,

    plock: 3,
    multp: rstem.multp,

    gifts: rstem.gifts,
    zname: rstem.btitle_zh,
  }
</script>

<Crumb items={crumb} />
<!-- <nav class="nav-list">
  {#each links as [mode, text, dtip]}
    <a
      href="{paths.curr}{mode}"
      class="nav-link"
      class:_active={mode == $page.data.rmode}
      data-tip={dtip}>
      <span>{text}</span>
    </a>
  {/each}
</nav> -->
<Reader {cstem} {ropts} {rdata} />

<Footer>
  <div class="navi">
    <a
      href={prev_path}
      class="m-btn navi-item"
      class:_disable={!rdata._prev}
      data-key="74"
      data-kbd="←">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <a
      href="{sroot}{ch_no > 32 ? `?pg=${_pgidx(ch_no)}` : ''}"
      class="m-btn _success"
      data-kbd="h">
      <SIcon name="list" />
      <span class="u-show-tm">Mục lục</span>
    </a>

    <a
      href={next_path}
      class="m-btn _fill navi-item"
      class:_primary={rdata._next}
      data-key="75"
      data-kbd="→">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Footer>

<style lang="scss">
  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
