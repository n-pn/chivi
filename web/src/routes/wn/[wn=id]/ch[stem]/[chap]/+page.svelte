<script lang="ts">
  import { seed_path, chap_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Crumb from '$gui/molds/Crumb.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, curr_seed, rdata, ropts } = data)

  $: ch_no = rdata.ch_no
  // $: total = curr_seed.chap_max

  $: stem_path = seed_path(nvinfo.bslug, curr_seed.sname)
  $: prev_path = rdata._prev
    ? chap_path(stem_path, rdata._prev, ropts)
    : stem_path

  $: next_path = rdata._next
    ? chap_path(stem_path, rdata._next, ropts)
    : stem_path

  import Reader from '$gui/shared/reader/Reader.svelte'

  $: crumb = [
    { text: nvinfo.vtitle, href: `/wn/${nvinfo.bslug}` },
    { text: `[${curr_seed.sname}]`, href: stem_path },
    { text: rdata.chdiv || 'Chính văn' },
    { text: rdata.title },
  ]

  $: cstem = {
    zname: nvinfo.ztitle,
    sname: curr_seed.sname,
    stype: 'wn',
    sn_id: curr_seed.sn_id,

    multp: curr_seed.multp,
    plock: curr_seed.privi,
    chmax: curr_seed.chmax,
    gifts: curr_seed.gifts,
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
      href="{stem_path}{ch_no > 32 ? `?pg=${_pgidx(ch_no)}` : ''}"
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
