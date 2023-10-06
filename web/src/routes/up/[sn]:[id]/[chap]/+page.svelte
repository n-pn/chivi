<script lang="ts">
  import { chap_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Crumb from '$gui/molds/Crumb.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ustem, rdata, ropts } = data)

  $: ch_no = rdata.ch_no
  // $: total = ustem.chmax || ustem.chap_count

  $: stem_path = `/up/${ustem.sname}:${data.up_id}`
  $: prev_path = rdata._prev
    ? chap_path(stem_path, rdata._prev, ropts)
    : stem_path

  $: next_path = rdata._next
    ? chap_path(stem_path, rdata._next, ropts)
    : stem_path

  import Reader from '$gui/shared/reader/Reader.svelte'

  $: crumb = [
    { text: 'Dự án cá nhân', href: `/up` },
    { text: ustem.vname, href: stem_path },
    { text: rdata.chdiv || 'Chính văn' },
    { text: rdata.title },
  ]

  $: rstem = {
    zname: ustem.zname,
    sname: ustem.sname,
    stype: 'up',
    sn_id: ustem.id.toString(),

    multp: ustem.multp,
    plock: 5,
    chmax: ustem.chap_count,
    gifts: ustem.gifts,
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
<Reader {rstem} {ropts} {rdata} />

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
