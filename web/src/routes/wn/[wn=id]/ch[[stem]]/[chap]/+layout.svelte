<script context="module" lang="ts">
  const main_tabs = [
    { type: 'ai', mode: 'auto', icon: 'language', text: 'Dịch máy' },
    { type: 'qt', icon: 'bolt', text: 'Dịch tạm' },
    { type: 'tl', icon: 'ballpen', text: 'Dịch tay' },
    { type: 'cf', icon: 'tool', text: 'Công cụ' },
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { api_call } from '$lib/api_call'
  import { afterNavigate } from '$app/navigation'
  import { seed_path, chap_path, _pgidx } from '$lib/kit_path'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Footer from '$gui/sects/Footer.svelte'

  import Crumb from '$gui/molds/Crumb.svelte'
  import Lookup2 from '$gui/parts/Lookup2.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ nvinfo, curr_seed, cinfo, xargs } = data)

  $: ch_no = cinfo.ch_no
  $: total = curr_seed.chmax

  $: croot = seed_path(nvinfo.bslug, curr_seed.sname)
  $: clist = ch_no > 32 ? `${croot}?pg=${_pgidx(ch_no)}` : croot
  $: paths = gen_paths(croot, cinfo, xargs)

  $: pager = new Pager($page.url, { part: 1, type: 'ai', mode: 'auto' })

  function gen_paths(croot: string, { ch_no, psize }, xargs) {
    const curr = chap_path(croot, ch_no, xargs)
    const prev = gen_prev_path(croot, ch_no, xargs)
    const next = gen_next_path(croot, ch_no, xargs, psize)
    return { curr, prev, next }
  }

  function gen_prev_path(croot: string, ch_no: number, xargs) {
    if (ch_no < 2) return croot

    const cpart = xargs.cpart

    if (cpart < 2) {
      return chap_path(croot, ch_no - 1, { ...xargs, cpart: -1 })
    } else {
      return chap_path(croot, ch_no, { ...xargs, cpart: cpart - 1 })
    }
  }

  function gen_next_path(croot: string, ch_no: number, xargs, psize: number) {
    const cpart = xargs.cpart
    if (cpart < psize) {
      return chap_path(croot, ch_no, { ...xargs, cpart: cpart + 1 })
    } else {
      return chap_path(croot, ch_no + 1, { ...xargs, cpart: 1 })
    }
  }

  afterNavigate(() => {
    update_memo(false)
  })

  async function update_memo(locking: boolean) {
    if ($_user.privi < 0) return

    const { ch_no, title, uslug } = cinfo
    const { sname } = curr_seed

    const path = `/_db/_self/books/${nvinfo.id}/access`
    const body = { sname, ch_no, cpart: data.cpart, title, uslug, locking }

    try {
      data.ubmemo = await api_call(path, body, 'PUT')
    } catch (ex) {
      console.log(ex)
    }
  }

  $: [on_memory, memo_icon] = check_memo(data.ubmemo)

  function check_memo(ubmemo: CV.Ubmemo): [boolean, string] {
    let on_memory = false
    if (ubmemo.sname == curr_seed.sname) {
      on_memory = ubmemo.chidx == cinfo.ch_no && ubmemo.cpart == data.cpart
    }

    if (!ubmemo.locked) return [on_memory, 'menu-2']
    return on_memory ? [true, 'bookmark'] : [false, 'bookmark-off']
  }

  $: crumb = [
    { text: 'Truyện chữ', href: `/wn` },
    { text: nvinfo.vtitle, href: `/wn/${nvinfo.bslug}` },
    { text: `Mục lục: [${curr_seed.sname}]`, href: croot },
    { text: cinfo.chdiv || 'Chính văn' },
    { text: cinfo.title },
  ]
</script>

<Crumb items={crumb}>
  {#if cinfo.psize > 1}
    <div class="crumb"><span>Phần {xargs.cpart}/{cinfo.psize}</span></div>
  {/if}
</Crumb>

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

<article class="article island">
  <header class="head">
    {#each main_tabs as { type, icon, text }}
      <a
        href={chap_path(croot, ch_no, { ...xargs, rtype: type, rmode: '' })}
        class="htab"
        class:_active={xargs.rtype == type}>
        <SIcon name={icon} />
        <span>{text}</span>
      </a>
    {/each}
  </header>
  <slot />
</article>

<Footer>
  <div class="navi">
    <a
      href={paths.prev}
      class="m-btn navi-item"
      class:_disable={ch_no < 2}
      data-key="74"
      data-kbd="←">
      <SIcon name="chevron-left" />
      <span>Trước</span>
    </a>

    <a
      href="{croot}{ch_no > 32 ? `?pg=${_pgidx(ch_no)}` : ''}"
      class="m-btn _success"
      data-kbd="h">
      <SIcon name="list" />
      <span class="u-show-tm">Mục lục</span>
    </a>

    {#if on_memory && data.ubmemo.locked}
      <button
        class="m-btn"
        disabled={$_user.privi < 0}
        on:click={() => update_memo(false)}
        data-kbd="p">
        <SIcon name="bookmark-off" />
        <span class="u-show-tm">Bỏ đánh dấu</span>
      </button>
    {:else}
      <button
        class="m-btn"
        disabled={$_user.privi < 0}
        on:click={() => update_memo(true)}
        data-kbd="p">
        <SIcon name="bookmark" />
        <span class="u-show-tm">Đánh dấu</span>
      </button>
    {/if}

    <a
      href={paths.next}
      class="m-btn _fill navi-item"
      class:_primary={ch_no < total}
      data-key="75"
      data-kbd="→">
      <span>Kế tiếp</span>
      <SIcon name="chevron-right" />
    </a>
  </div>
</Footer>

<Lookup2 />

<style lang="scss">
  .article {
    // @include bgcolor(tert);
    // @include shadow(2);
    @include padding-y(0);

    :global(.tm-warm) & {
      background-color: #fffbeb;
    }
    // @include tm-dark {
    //   @include linesd(--bd-soft, $ndef: false, $inset: false);
    // }
  }

  .head {
    display: flex;
    @include border(--bd-main, $loc: bottom);
  }

  .htab {
    @include flex-ca;
    flex-direction: column;
    padding: 0.5rem 0 0.25rem;

    font-weight: 500;
    flex: 1;

    --color: var(--fg-secd, #555);
    color: var(--color, inherit);

    > :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
      // opacity: 0.8;
    }

    > span {
      @include ftsize(sm);
    }

    @include bp-min(ts) {
      flex-direction: row;
      padding: 0.75rem 0;

      > :global(svg) {
        margin-right: 0.25rem;
      }

      > span {
        @include ftsize(md);
      }
    }

    &._active {
      --color: #{color(primary, 6)};
      position: relative;

      &:after {
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        content: '';
        @include border(primary, 5, $width: 2px, $loc: bottom);
      }

      @include tm-dark {
        --color: #{color(primary, 4)};
      }
    }

    // &.disabled {
    //   --color: var(--fg-mute);
    // }
  }

  .navi {
    @include flex($center: horz, $gap: 0.5rem);
  }
</style>
