<script context="module" lang="ts">
  const main_tabs = [
    { type: 'ai', mode: 'auto', icon: 'language', text: 'Dịch máy' },
    { type: 'qt', icon: 'bolt', text: 'Dịch tạm' },
    { type: 'tl', icon: 'ballpen', text: 'Dịch tay' },
    { type: 'cf', icon: 'tool', text: 'Công cụ' },
  ]

  type ReadMode = Record<string, { text: string; desc: string }>
  const read_modes: Record<string, ReadMode> = {
    ai: {
      avail: {
        text: 'Đã có sẵn',
        desc: 'Chọn kết quả phân tích ngữ pháp có sẵn, ưu tiên Ernie Gram',
      },
      hm_eg: {
        text: 'Ernie Gram',
        desc: 'HanLP Closed-source MTL ERNIE_GRAM_ZH',
      },
      hm_eb: {
        text: 'Electra Base',
        desc: 'HanLP Closed-source MTL ELECTRA_BASE_ZH',
      },
    },

    qt: {
      be_zv: {
        text: 'Bing Edge',
        desc: 'Dịch bằng Bing Translator thông qua Edge API',
      },
      qt_v1: {
        text: 'Máy dịch cũ',
        desc: 'Kết quả dịch từ máy dịch phiên bản cũ',
      },
      hviet: {
        text: 'Hán Việt',
        desc: 'Dịch ra kết quả phiên âm Hán Việt',
      },
    },
    tl: {
      basic: {
        text: 'Cơ bản',
        desc: 'Kết quả dịch tay do người dùng khởi tạo/sửa chữa',
      },
      mixed: {
        text: 'Trộn lẫn',
        desc: 'Trộn kết quả dịch tay đã kiểm chứng với kết quả dịch máy',
      },
      other: {
        text: 'Sưu tầm',
        desc: '',
      },
    },
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import { config, get_user } from '$lib/stores'
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

  $: ({ nvinfo, curr_seed, cinfo, rdata, xargs } = data)

  $: ch_no = cinfo.ch_no
  $: total = curr_seed.chmax

  $: croot = seed_path(nvinfo.bslug, curr_seed.sname)
  $: paths = gen_paths(croot, cinfo, xargs)

  $: zpath = `${rdata.cbase}-${xargs.cpart}`
  $: pdict = `book/${xargs.wn_id}`

  $: pager = new Pager($page.url, { part: 1, type: 'ai', mode: 'auto' })

  function gen_paths(croot: string, { ch_no, psize }, xopts: CV.Chopts) {
    const curr = chap_path(croot, ch_no, xopts)
    const prev = gen_prev_path(croot, ch_no, xopts)
    const next = gen_next_path(croot, ch_no, xopts, psize)
    return { curr, prev, next }
  }

  function gen_prev_path(croot: string, ch_no: number, xopts: CV.Chopts) {
    if (ch_no < 2) return croot

    const cpart = xopts.cpart

    if (cpart < 2) {
      return chap_path(croot, ch_no - 1, { ...xopts, cpart: -1 })
    } else {
      return chap_path(croot, ch_no, { ...xopts, cpart: cpart - 1 })
    }
  }

  function gen_next_path(croot: string, ch_no: number, xopts, psize: number) {
    const cpart = xopts.cpart
    if (cpart < psize) {
      return chap_path(croot, ch_no, { ...xopts, cpart: cpart + 1 })
    } else {
      return chap_path(croot, ch_no + 1, { ...xopts, cpart: 1 })
    }
  }

  import {
    data as lookup_data,
    ctrl as lookup_ctrl,
    type Data as LookupData,
  } from '$lib/stores/lookup_stores'
  import { rel_time_vp } from '$utils/time_utils'
  import { browser } from '$app/environment'

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

  let on_focus: HTMLElement
  let reader: HTMLDivElement
  let change_mode = false

  const handle_click = (event: MouseEvent) => {
    let target = event.target as HTMLElement

    while (target != reader) {
      if (target.classList.contains('cdata')) break
      target = target.parentElement
    }

    if (target == reader) return
    l_idx = +target.dataset.line
    lookup_ctrl.show(true)
  }

  let l_idx = -1
  $: l_max = ($page.data.lines || []).length

  afterNavigate(() => {
    l_idx = -1
    if (on_focus) on_focus.classList.remove('focus')
    update_memo(false)
  })

  $: zsize = data.rdata.sizes[xargs.cpart]

  $: if (browser && l_idx >= 0) {
    const new_focus = document.getElementById('L' + l_idx)

    if (new_focus != on_focus) {
      if (on_focus) on_focus.classList.remove('focus')
      on_focus = new_focus
      on_focus.classList.add('focus')
      on_focus.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }

    lookup_ctrl.show(true)
  }

  $: {
    let rmode = xargs.rmode
    let m_alg = ''
    let zdata = $page.data.lines

    if (xargs.rtype == 'ai') {
      rmode = 'ctree'
      m_alg = xargs.rmode
    } else if (rmode == 'be_zv') {
      rmode = 'btran'
    } else if (rmode == 'hviet') {
      zdata = []
    }

    lookup_data.put(zpath, pdict, { [rmode]: zdata, m_alg })
  }
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

  <section class="mode-nav">
    <div class="rmode">
      <span class="chip-text">Cách dịch:</span>
      <button
        class="chip-link _active"
        on:click={() => (change_mode = !change_mode)}>
        <span>{read_modes[xargs.rtype][xargs.rmode].text}</span>
        <SIcon name="chevron-down" />
      </button>
    </div>

    <div class="chap-stat">
      <div class="stat-group">
        <span class="stat-entry" data-tip="Số ký tự tiếng Trung">
          <SIcon name="file-analytics" />
          <span class="stat-value">{zsize}</span>
          <span class="stat-label"> chữ</span>
        </span>
        {#if $page.data.tspan}
          <div class="stat-entry" data-tip="Thời gian chạy máy dịch">
            <SIcon name="clock" />
            <span class="stat-value">{$page.data.tspan}ms</span>
          </div>
        {/if}

        {#if $page.data.mtime}
          <div class="stat-entry" data-tip="Thay đổi lần cuối">
            <SIcon name="calendar" />
            <span class="stat-value">{rel_time_vp($page.data.mtime)}</span>
          </div>
        {/if}
      </div>
    </div>
  </section>

  {#if change_mode}
    <nav class="rmode-choice">
      <span class="chip-text">Đổi sang:</span>
      {#each Object.entries(read_modes[xargs.rtype]) as [mode, { text, desc }]}
        <a
          href={pager.gen_url({ mode, part: xargs.cpart })}
          class="chip-link"
          class:_active={xargs.rmode == mode}
          data-tip={desc}
          on:click={() => (change_mode = false)}>
          <span>{text}</span>
        </a>
      {/each}
    </nav>
  {/if}

  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div
    bind:this={reader}
    class="reader app-fs-{$config.ftsize} app-ff-{$config.ftface}"
    style:--textlh="{$config.textlh}%"
    on:click|capture={handle_click}>
    <slot />
  </div>
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

<div hidden>
  <button
    type="button"
    data-kbd="↑"
    disabled={l_idx == 0}
    on:click={() => (l_idx -= 1)} />
  <button
    type="button"
    data-kbd="↓"
    on:click={() => (l_idx += 1)}
    disabled={l_idx == l_max} />
</div>

<Lookup2 bind:l_idx {l_max} />

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

  .reader {
    @include border(--bd-soft, $loc: top);

    padding: 0.75rem 0;
    display: block;
    min-height: 50vh;
    @include fgcolor(secd);

    :global(cite) {
      font-style: normal;
      font-variant: small-caps;
    }

    :global(.cdata) {
      cursor: pointer;
      @include bp-min(tl) {
        @include padding-x(var(--gutter));
      }
    }

    // @include border(--bd-soft, $loc: top);
  }

  .mode-nav {
    @include padding-y(0.5rem);
    display: flex;
  }

  .chap-stat {
    display: inline-flex;
    margin-left: auto;
  }

  .stat-group {
    display: inline-flex;
    align-items: center;

    // @include padding-x(0.75rem);
    // @include padding-y(0.25rem);

    @include ftsize(sm);
    @include fgcolor(mute);
  }

  .stat-entry {
    display: inline-flex;
    align-items: center;

    & + &:before {
      content: ' ';
      margin: 0 0.25rem;
    }
  }

  .stat-label {
    display: none;
    font-style: italic;

    @include bp-min(ts) {
      display: inline-block;

      .stat-value + & {
        margin-left: 0.125rem;
      }
      & + :global(svg) {
        display: none;
      }
    }
  }

  .stat-value {
    margin-left: 0.125rem;
    // font-weight: 500;
    @include fgcolor(tert);

    &._link {
      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  .rmode-choice {
    padding-bottom: 0.5rem;
    @include flex-cy;
    gap: 0.5rem;
  }
</style>
