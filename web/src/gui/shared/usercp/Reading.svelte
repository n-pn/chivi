<script lang="ts" context="module">
  const stypes = [
    ['', 'Tất cả'],
    ['wn', 'Truyện chữ'],
    ['up', 'Sưu tầm'],
    ['rm', 'Liên kết'],
  ]
</script>

<script lang="ts">
  import type { Writable } from 'svelte/store'

  import { status_names, status_icons } from '$lib/constants'
  import { chap_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { get_rtime } from '$gui/atoms/RTime.svelte'

  export let _user: Writable<App.CurrentUser>

  let memos: Array<CV.Rdmemo> = []
  let stype = ''
  let cmark = false
  let pg_no = 1

  $: load_history(stype, pg_no)

  async function load_history(stype = '', pg = 1) {
    const rdurl = `/_rd/rdmemos?sname=${stype}&rtype=rdlog&pg=${pg}&lm=15`
    const res = await fetch(rdurl)

    if (!res.ok) {
      alert(await res.text())
      return
    }

    const data = await res.json()
    memos = data.items
  }

  const gen_cdata = (rmemo: CV.Rdmemo, cmark: boolean = false) => {
    const ch_no = cmark ? rmemo.mark_ch_no : rmemo.last_ch_no
    const cinfo = cmark ? rmemo.mark_cinfo : rmemo.last_cinfo
    const chref = chap_path(rmemo.rpath, ch_no, cinfo)
    return { ch_no, cinfo, chref }
  }
</script>

<h4 class="label">
  <SIcon name="book" />
  <span>Truyện chữ</span>
</h4>

<div class="m-chips">
  {#each ['reading', 'onhold', 'pending'] as status}
    {@const icon = status_icons[status]}
    <a href="/me/books/{status}" class="m-chip">
      <SIcon name={icon} />
      {status_names[status]}
    </a>
  {/each}
</div>

<!-- <h4 class="label">
  <SIcon name="album" />
  <span>Sưu tầm</span>
</h4>

<div class="chips">
  {#each ['liked', 'owner'] as status}
    {@const icon = status_icons[status]}
    <a href="/me/books/{status}" class="chip">
      <SIcon name={icon} />
      {status_names[status]}
    </a>
  {/each}
</div> -->

<h4 class="label">
  <SIcon name="clock" />
  <span>Lịch sử đọc</span>
</h4>

<div class="m-chips filter">
  <span class="u-fz-sm u-fg-tert">Lọc:</span>
  {#each stypes as [_type, label]}
    <button
      class="m-chip _xs _primary"
      class:_active={stype == _type}
      on:click={() => (stype = _type)}>
      {label}</button>
  {/each}
</div>

<div class="chlist">
  {#each memos as rmemo}
    {@const cdata = gen_cdata(rmemo, cmark)}

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
          <SIcon name={cmark ? 'bookmark' : 'eye'} />
        </div>
      </div>
    </a>
  {/each}
</div>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .label {
    @include flex();
    margin: 0.25rem 0;

    line-height: 2.25rem;
    font-weight: 500;

    @include fgcolor(tert);

    :global(svg) {
      margin-top: 0.625rem;
      width: 1rem;
      height: 1rem;
    }

    span {
      margin-left: 0.25rem;
    }
  }

  h4.label {
    margin-top: 0.75rem;
    @include border(--bd-soft, $loc: top);
  }

  .filter {
    margin-bottom: 1rem;
    @include flex-cx;
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
