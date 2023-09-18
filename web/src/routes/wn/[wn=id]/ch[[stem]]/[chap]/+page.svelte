<script context="module" lang="ts">
  const modes = {
    avail: {
      text: 'Đã có sẵn',
      desc: 'Chọn kết quả phân tích ngữ pháp có sẵn, ưu tiên Ernie G',
    },
    hm_eg: {
      text: 'Ernie Gram',
      desc: 'HanLP Closed-source MTL ERNIE_GRAM_ZH',
    },
    hm_eb: {
      text: 'Electra Base',
      desc: 'HanLP Closed-source MTL ELECTRA_BASE_ZH',
    },
  }

  // const secd_tabs = {
  //   qt: [
  //     {
  //       mode: 'qt_v1',
  //       text: 'Máy dịch cũ',
  //       desc: 'Kết quả dịch từ máy dịch phiên bản cũ',
  //     },
  //     {
  //       mode: 'be_zv',
  //       text: 'Bing Edge',
  //       desc: 'Dịch bằng Bing Translator thông qua Edge API',
  //     },
  //     {
  //       mode: 'qt_hv',
  //       text: 'Hán Việt',
  //       desc: 'Dịch ra kết quả phiên âm Hán Việt',
  //     },
  //   ],
  //   tl: [
  //     {
  //       mode: 'basic',
  //       text: 'Cơ bản',
  //       desc: 'Kết quả dịch tay do người dùng khởi tạo/sửa chữa',
  //     },
  //     {
  //       mode: 'mixed',
  //       text: 'Trộn lẫn',
  //       desc: 'Trộn kết quả dịch tay đã kiểm chứng với kết quả dịch máy',
  //     },
  //     {
  //       mode: 'other',
  //       text: 'Sưu tầm',
  //       desc: '',
  //     },
  //   ],
  // }
</script>

<script lang="ts">
  import { afterNavigate } from '$app/navigation'

  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'
  import { config } from '$lib/stores'
  import { gen_vtran_html } from '$lib/mt_data_2'

  import {
    data as lookup_data,
    ctrl as lookup_ctrl,
  } from '$lib/stores/lookup_stores'

  import SIcon from '$gui/atoms/SIcon.svelte'

  // let error = ''

  // import { get_user } from '$lib/stores'
  // const _user = get_user()

  import type { PageData } from './$types'
  export let data: PageData

  $: pager = new Pager($page.url, { part: 1, mode: 'avail' })

  $: cinfo = data.cinfo
  $: rdata = data.rdata
  $: xargs = data.xargs

  $: tspan = data.tspan
  $: zsize = data.rdata.sizes[xargs.cpart]

  let reader: HTMLDivElement
  let change_mode = false

  $: zpath = `${rdata.cbase}-${xargs.cpart}`
  $: pdict = `book/${xargs.wn_id}`

  let on_focus: HTMLElement

  const change_focus = async (l_idx: number) => {
    const new_focus = document.getElementById('L' + l_idx)

    if (new_focus != on_focus) {
      if (on_focus) on_focus.classList.remove('focus')

      on_focus = new_focus
      on_focus.classList.add('focus')

      on_focus.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
      await lookup_data.from_cdata(data.lines, l_idx, zpath, pdict)
    }

    lookup_ctrl.show()
  }

  $: render_mode = $config.r_mode == 2 ? 2 : 1

  afterNavigate(() => {
    $lookup_data.l_idx = -1
    if (on_focus) on_focus.classList.remove('focus')
  })

  $: if ($lookup_data.l_idx > -1) change_focus($lookup_data.l_idx)
</script>

<section class="mode-nav">
  <div class="rmode">
    <span class="chip-text">Cách dịch:</span>
    <button
      class="chip-link _active"
      on:click={() => (change_mode = !change_mode)}>
      <span>{modes[xargs.rmode].text}</span>
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
      <div class="stat-entry" data-tip="Thời gian chạy máy dịch">
        <SIcon name="clock" />
        <span class="stat-value">{tspan}ms</span>
      </div>
    </div>
  </div>
</section>

{#if change_mode}
  <nav class="rmode-choice">
    <span class="chip-text">Đổi sang:</span>
    {#each Object.entries(modes) as [mode, { text, desc }]}
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

<div
  bind:this={reader}
  class="reader app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  style:--textlh="{$config.textlh}%">
  {#each data.lines as line, _idx}
    {@const opts = { mode: render_mode, cap: true, und: true, _qc: 0 }}
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <svelte:element
      this={_idx > 0 ? 'p' : 'h1'}
      id="L{_idx}"
      class="cdata"
      on:click={() => ($lookup_data.l_idx = _idx)}>
      {@html gen_vtran_html(line, opts)}
      {#if _idx == 0 && cinfo.psize > 1}[{xargs.cpart}/{cinfo.psize}]{/if}
    </svelte:element>
  {/each}
</div>

<div hidden>
  <button type="button" data-kbd="↑" on:click={lookup_data.move_up} />
  <button type="button" data-kbd="↓" on:click={lookup_data.move_down} />
</div>

<style lang="scss">
  .cdata {
    cursor: pointer;
    @include bp-min(tl) {
      @include padding-x(var(--gutter));
    }
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
