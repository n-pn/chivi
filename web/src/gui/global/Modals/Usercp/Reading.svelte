<script lang="ts">
  import { onMount } from 'svelte'
  import type { Writable } from 'svelte/store'

  import { status_names, status_icons } from '$lib/constants'
  import { chap_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { get_rtime } from '$gui/atoms/RTime.svelte'

  export let _user: Writable<App.CurrentUser>

  let chaps: Array<any>
  let kind = ''

  onMount(load_history)

  async function load_history(kind = '', pg = 1) {
    const api_url = `/_db/_self/books/access?kind=${kind}&pg=${pg}&lm=15`
    const api_res = await fetch(api_url)

    if (api_res.ok) chaps = await api_res.json()
    else console.log(await api_res.text())
  }

  const chap_href = ({ bslug, sname, chidx: ch_no, cpart, uslug }) =>
    chap_path(bslug, sname, ch_no, cpart, uslug)
</script>

<div class="chips">
  {#each ['reading', 'onhold', 'pending'] as status}
    {@const icon = status_icons[status]}
    <a href="/@{$_user.uname}/books/{status}" class="chip">
      <SIcon name={icon} />
      {status_names[status]}
    </a>
  {/each}
</div>

<h4 class="label">
  <SIcon name="clock" />
  <span>Lịch sử đọc</span>
</h4>

<div class="chips filter">
  <button
    class="chip _small"
    class:_active={kind == ''}
    on:click={() => (kind = '')}>Vừa truy cập</button>
  <button
    class="chip _small"
    class:_active={kind == 'stored'}
    on:click={() => (kind = 'stored')}>Trong tủ truyện</button>
  <button
    class="chip _small"
    class:_active={kind == 'marked'}
    on:click={() => (kind = 'marked')}>Đã đánh dấu</button>
</div>

<div class="chlist">
  {#each chaps || [] as chap}
    {@const href = chap_href(chap)}
    {@const type = chap.locked
      ? 'bookmark'
      : chap.status != 'default'
      ? 'book'
      : 'eye'}

    <a class="chap" {href}>
      <div class="chap-text">
        <div class="chap-title">{chap.title}</div>
        <div class="chap-chidx">{chap.chidx}.</div>
      </div>

      <div class="chap-meta">
        <div class="chap-bname">{chap.bname}</div>
        <div
          class="chap-state"
          data-tip="Xem: {get_rtime(chap.utime)}"
          data-tip-pos="right">
          <SIcon name={type} />
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
    @include border($loc: top);
  }

  .chips {
    @include flex($center: horz);
    @include bps(font-size, 12px, 12px, 13px);
  }

  .chip {
    display: inline-flex;
    border-radius: 0.75rem;
    align-items: center;

    padding: 0 0.75em;
    line-height: 2.25em;
    font-weight: 500;
    text-transform: uppercase;

    @include fgcolor(tert);
    @include bgcolor(tert);
    @include linesd(var(--bd-main));

    &:hover,
    &._active {
      @include linesd(primary, 4, $ndef: false);
      @include fgcolor(primary, 5);
    }

    @include tm-dark {
      &:hover,
      &._active {
        @include linesd(primary, 5, $ndef: false);
        @include fgcolor(primary, 4);
      }
    }

    & + & {
      @include bps(margin-left, 0.25rem, 0.375rem);
    }

    &._small {
      line-height: 2em;
      text-transform: none;
      // @include ftsize(xs);
    }

    :global(svg) {
      width: 1.25em;
      height: 1.25em;
      margin-right: 0.25em;
    }
  }

  .filter {
    margin-bottom: 1rem;
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
