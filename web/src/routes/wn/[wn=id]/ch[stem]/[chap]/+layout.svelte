<script context="module" lang="ts">
  const main_tabs = [
    { type: 'ai', mode: 'auto', icon: 'language', text: 'Dịch máy' },
    { type: 'qt', icon: 'bolt', text: 'Dịch thô' },
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
      mtl_1: {
        text: 'Electra Small',
        desc: 'HanLP_Closed_MTL_ELECTRA_SMALL_ZH',
      },
      mtl_2: {
        text: 'Electra Base',
        desc: 'HanLP_Closed_MTL_ELECTRA_BASE_ZH',
      },
      mtl_3: {
        text: 'Ernie Gram',
        desc: 'HanLP Closed-source MTL ERNIE_GRAM_ZH',
      },
    },

    qt: {
      qt_v1: {
        text: 'Máy dịch cũ',
        desc: 'Kết quả dịch từ máy dịch phiên bản cũ',
      },
      be_zv: {
        text: 'Bing Edge',
        desc: 'Dịch bằng Bing Translator thông qua Edge API',
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

  $: stem_path = seed_path(nvinfo.bslug, curr_seed.sname)
  $: prev_path = rdata._prev
    ? chap_path(stem_path, rdata._prev, xargs)
    : stem_path

  $: next_path = rdata._succ
    ? chap_path(stem_path, rdata._succ, xargs)
    : stem_path

  $: pager = new Pager($page.url, { type: 'ai', mode: 'auto' })

  import {
    data as lookup_data,
    ctrl as lookup_ctrl,
  } from '$lib/stores/lookup_stores'
  import { rel_time_vp } from '$utils/time_utils'
  import { browser } from '$app/environment'
  import Notext from './Notext.svelte'

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
    { text: nvinfo.vtitle, href: `/wn/${nvinfo.bslug}` },
    { text: `[${curr_seed.sname}]`, href: stem_path },
    { text: cinfo.chdiv || 'Chính văn' },
    { text: cinfo.title },
  ]

  let on_focus: HTMLElement
  let reader: HTMLDivElement
  let change_mode = false

  const handle_mouse = (event: MouseEvent, panel: string = 'overview') => {
    let target = event.target as HTMLElement

    while (target != reader) {
      if (target.classList.contains('cdata')) break
      target = target.parentElement
    }

    if (target == reader) return

    event.preventDefault()

    l_idx = +target.dataset.line
    lookup_ctrl.show(panel)
  }

  let l_idx = -1
  $: l_max = rdata.ztext.length

  afterNavigate(() => {
    l_idx = -1
    if (on_focus) on_focus.classList.remove('focus')
    update_memo(false)
  })

  $: if (browser && l_idx >= 0) {
    const new_focus = document.getElementById('L' + l_idx)

    if (new_focus != on_focus) {
      if (on_focus) on_focus.classList.remove('focus')
      on_focus = new_focus
      on_focus.classList.add('focus')
      on_focus.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }

    lookup_ctrl.show()
  }

  $: vtran = $page.data.vtran || {}
  $: update_lookup_data(vtran)

  function update_lookup_data({ lines: zdata }) {
    let { rmode, rtype } = xargs
    let m_alg = ''

    let ztext = rdata.ztext

    if (rmode == 'qt_v1') {
      rmode = 'qtran'
    } else if (rmode == 'be_zv') {
      rmode = 'btran'
    } else if (rmode == 'hviet') {
      zdata = []
    } else if (rtype == 'ai') {
      rmode = 'ctree'
      m_alg = xargs.rmode
    } else {
      rmode = 'ctree'
      zdata = []
    }

    const data = { zpage: xargs.zpage, ztext, [rmode]: zdata, m_alg }
    lookup_data.put(data)
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

<article
  class="article island app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  style:--textlh="{$config.textlh}%">
  <header class="head">
    {#each main_tabs as { type, icon, text }}
      <a
        href={chap_path(stem_path, ch_no, { rtype: type, rmode: '' })}
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
        <span>{read_modes[xargs.rtype][xargs.rmode]?.text}</span>
        <SIcon name="chevron-down" />
      </button>
    </div>

    <div class="chap-stat">
      <div class="stat-group">
        <span class="stat-entry" data-tip="Số ký tự tiếng Trung">
          <SIcon name="file-analytics" />
          <span class="stat-value">{rdata.zsize}</span>
          <span class="stat-label"> chữ</span>
        </span>
        {#if vtran?.tspan}
          <div class="stat-entry" data-tip="Thời gian chạy máy dịch">
            <SIcon name="clock" />
            <span class="stat-value">{vtran.tspan}ms</span>
          </div>
        {/if}

        {#if vtran?.mtime}
          <div class="stat-entry" data-tip="Thay đổi lần cuối">
            <SIcon name="calendar" />
            <span class="stat-value">{rel_time_vp(vtran.mtime)}</span>
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

  {#if data.error}
    <Notext {data} />
  {:else if $page.data.vtran.error}
    <section class="error">
      <h1>Lỗi hệ thống:</h1>
      <p class="error-message">{$page.data.vtran.error}</p>
    </section>
  {:else}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div
      class="reader"
      bind:this={reader}
      on:click|capture={(e) => handle_mouse(e, 'overview')}
      on:contextmenu|capture={(e) => handle_mouse(e, 'glossary')}>
      <slot />
    </div>
  {/if}
</article>

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
      href={next_path}
      class="m-btn _fill navi-item"
      class:_primary={rdata._succ}
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

  .error {
    padding: var(--gutter);
  }
</style>
