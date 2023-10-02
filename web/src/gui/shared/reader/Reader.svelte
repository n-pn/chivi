<script context="module" lang="ts">
  const read_tabs = [
    { type: 'tl', icon: 'ballpen', text: 'Dịch tay' },
    { type: 'mt', icon: 'language', text: 'Dịch máy' },
    { type: 'cf', icon: 'tool', text: 'Công cụ' },
  ]
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'

  import {
    call_mtran_file,
    call_btran_file,
    call_qtran_file,
  } from '$utils/tran_util'

  import { afterNavigate } from '$app/navigation'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import Lookup2 from '$gui/parts/Lookup2.svelte'

  import {
    data as lookup_data,
    ctrl as lookup_ctrl,
  } from '$lib/stores/lookup_stores'

  import { browser } from '$app/environment'
  import { config } from '$lib/stores'
  import { rel_time_vp } from '$utils/time_utils'

  import Nodata from './Nodata.svelte'
  import Switch from './Switch.svelte'
  import Status from './Status.svelte'

  export let rstem: CV.Rdstem
  export let xargs: CV.Chopts
  export let rdata: CV.Chpart

  export let ftype = rdata.fpath.split(/[:\/\-]/)

  $: pager = new Pager($page.url, { type: 'tl', mode: 'avail' })

  let reader: HTMLDivElement

  let focused_node: HTMLElement

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
    if (focused_node) focused_node.classList.remove('focus')
  })

  $: if (browser && l_idx >= 0) {
    const new_focus = document.getElementById('L' + l_idx)

    if (new_focus != focused_node) {
      if (focused_node) focused_node.classList.remove('focus')
      focused_node = new_focus
      focused_node.classList.add('focus')
      focused_node.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }

    lookup_ctrl.show()
  }

  let vtran: CV.Mtdata | CV.Qtdata

  let error = ''

  $: load_data(xargs)

  $: init_data = { zpage: xargs.zpage, ztext: rdata.ztext }

  async function load_data(xargs: CV.Chopts, rinit: RequestInit = {}) {
    const { zpage, rtype, rmode, m_alg = rmode || 'avail' } = xargs
    const finit = { ...zpage, m_alg, force: true }

    let xtype = ''

    if (rtype == 'mt') {
      vtran = await call_mtran_file(finit, rinit, fetch)
      xtype = 'ctree'
    } else if (rmode == 'qt_v1') {
      vtran = await call_qtran_file(finit, rinit, fetch)
      xtype = 'qtran'
    } else if (rmode == 'be_zv') {
      vtran = await call_btran_file(finit, rinit, fetch)
      xtype = 'btran'
    }

    error = vtran.error
    if (!error) lookup_data.put({ ...init_data, [xtype]: vtran.lines })
  }

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

<article
  class="article island app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  style:--textlh="{$config.textlh}%">
  <header class="head">
    {#each read_tabs as { type, icon, text }}
      <a
        href={pager.gen_url({ type, mode: '' })}
        class="htab"
        class:_active={xargs.rtype == type}>
        <SIcon name={icon} />
        <span>{text}</span>
      </a>
    {/each}
  </header>

  <Switch {pager} {xargs} />

  <section class="mode-nav">
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

  {#if rdata.error}
    <Nodata {rstem} {rdata} {xargs} />
  {:else if vtran.error}
    <section class="error">
      <h1>Lỗi hệ thống:</h1>
      <p class="error-message">{vtran.error}</p>
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
