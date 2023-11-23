<script lang="ts" context="module">
  const stypes = [
    ['', 'Không phân loại'],
    ['wn', 'Truyện chữ'],
    ['up', 'Sưu tầm'],
    ['rm', 'Nguồn nhúng'],
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'

  import { chap_path, _pgidx } from '$lib/kit_path'
  import { get_rtime } from '$gui/atoms/RTime.svelte'
  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let rdmark = false

  $: props = data.props

  const gen_cdata = (rmemo: CV.Rdmemo, cmark: boolean = false) => {
    const ch_no = cmark ? rmemo.mark_ch_no : rmemo.last_ch_no
    const cinfo = cmark ? rmemo.mark_cinfo : rmemo.last_cinfo
    const chref = chap_path(rmemo.rpath, ch_no, cinfo)
    return { ch_no, cinfo, chref }
  }

  $: pager = new Pager($page.url, { pg: 1, sn: '' })
</script>

<nav class="links">
  <span class="label">Lọc:</span>
  {#each stypes as [filter, label]}
    <a
      class="m-btn _xs _primary"
      class:_fill={data.filter.sname == filter}
      href={pager.gen_url({ pg: 1, sn: filter })}>{label}</a>
  {/each}

  <!-- <div class="right">
    <button
      class="m-btn _xs _primary"
      class:_fill={!data.rdmark}
      on:click={() => (data.rdmark = false)}>Vừa xem</button>

    <button
      class="m-btn _xs _primary"
      class:_fill={data.rdmark}
      on:click={() => (data.rdmark = true)}>Tuần tự</button>
  </div> -->
</nav>

<div class="chaps">
  {#each props.items || [] as rmemo}
    {@const cdata = gen_cdata(rmemo, rdmark)}

    <a class="chap" href={cdata.chref}>
      <div class="chap-text">
        <div class="chap-title">{cdata.cinfo.title}</div>
        <div class="chap-chidx">{cdata.ch_no}.</div>
      </div>

      <div class="chap-meta">
        <div class="chap-bname">
          [{rmemo.sname}] {rmemo.vname}
        </div>
        <div
          class="chap-state"
          data-tip="Xem: {get_rtime(rmemo.rtime)}"
          data-tip-pos="right">
          <SIcon name={rdmark ? 'bookmark' : 'eye'} />
        </div>
      </div>
    </a>
  {/each}
</div>

<footer>
  <Mpager {pager} pgidx={props.pgidx} pgmax={props.pgmax} />
</footer>

<style lang="scss">
  .links {
    margin-bottom: 1rem;

    @include flex-ca($gap: 0.5rem);
    // flex-direction: column;
    .m-btn {
      border-radius: 1rem;
      padding: 0 0.5rem;
    }

    .right {
      margin-left: auto;
    }
  }

  .chaps {
    margin-bottom: 0.5rem;
  }

  .chap {
    display: block;
    @include border(--bd-main, $loc: bottom);

    padding: 0.375rem 0.5rem;
    user-select: none;

    &:first-child {
      @include border(--bd-main, $loc: top);
    }

    &:nth-child(odd) {
      background: var(--bg-main);
    }
  }

  // prettier-ignore
  .chap-title {
    flex: 1;
    margin-right: 0.125rem;
    @include fgcolor(secd);
    @include clamp($width: null);

    .chap:visited & { @include fgcolor(neutral, 5); }
    .chap:hover & { @include fgcolor(primary, 5); }
  }

  .chap-text {
    display: flex;
    line-height: 1.5rem;
  }

  .chap-meta {
    @include flex($gap: 0.25rem);
    padding: 0;
    line-height: 1rem;
    margin-top: 0.25rem;
    text-transform: uppercase;

    @include ftsize(xs);
    @include fgcolor(neutral, 5);
  }

  .chap-chidx {
    @include fgcolor(tert);
    @include ftsize(xs);
  }

  .chap-state {
    @include fgcolor(tert);
    position: relative;
    font-size: 1rem;
    margin-top: -0.125rem;
  }

  .chap-bname {
    flex: 1 1;
    @include clamp($width: null);
  }
</style>
