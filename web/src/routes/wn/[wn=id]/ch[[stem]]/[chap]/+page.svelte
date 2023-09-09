<script context="module" lang="ts">
  const main_tabs = [
    { type: 'mt', mode: 'auto', icon: 'language', text: 'Dịch máy' },
    { type: 'qt', icon: 'bolt', text: 'Dịch tạm' },
    { type: 'tl', icon: 'ballpen', text: 'Dịch tay' },
    { type: 'cf', icon: 'tool', text: 'Công cụ' },
  ]

  const mt_mode_tabs = [
    {
      mode: 'avail',
      text: 'Có sẵn',
      desc: 'Chọn kết quả phân tích ngữ pháp có sẵn, ưu tiên Ernie Gram',
    },
    {
      mode: 'hm_eg',
      text: 'Ernie Gram',
      desc: 'HanLP Closed-source MTL ERNIE_GRAM_ZH',
    },
    {
      mode: 'hm_eb',
      text: 'Electra Base',
      desc: 'HanLP Closed-source MTL ELECTRA_BASE_ZH',
    },
  ]

  const secd_tabs = {
    mt: [
      {
        mode: 'avail',
        text: 'Có sẵn',
        desc: 'Chọn kết quả phân tích ngữ pháp có sẵn, ưu tiên Ernie Gram',
      },
      {
        mode: 'hm_eg',
        text: 'Ernie Gram',
        desc: 'HanLP Closed-source MTL ERNIE_GRAM_ZH',
      },
      {
        mode: 'hm_eb',
        text: 'Electra Base',
        desc: 'HanLP Closed-source MTL ELECTRA_BASE_ZH',
      },
    ],
    qt: [
      {
        mode: 'qt_v1',
        text: 'Máy dịch cũ',
        desc: 'Kết quả dịch từ máy dịch phiên bản cũ',
      },
      {
        mode: 'be_zv',
        text: 'Bing Edge',
        desc: 'Dịch bằng Bing Translator thông qua Edge API',
      },
      {
        mode: 'qt_hv',
        text: 'Hán Việt',
        desc: 'Dịch ra kết quả phiên âm Hán Việt',
      },
    ],
    tl: [
      {
        mode: 'basic',
        text: 'Cơ bản',
        desc: 'Kết quả dịch tay do người dùng khởi tạo/sửa chữa',
      },
      {
        mode: 'mixed',
        text: 'Trộn lẫn',
        desc: 'Trộn kết quả dịch tay đã kiểm chứng với kết quả dịch máy',
      },
      {
        mode: 'other',
        text: 'Sưu tầm',
        desc: '',
      },
    ],
  }
</script>

<script lang="ts">
  import { page } from '$app/stores'
  import { Pager } from '$lib/pager'
  import { config } from '$lib/stores'
  import { render_cdata } from '$lib/mt_data_2'

  import { rel_time } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  // import { get_user } from '$lib/stores'
  // const _user = get_user()

  import type { PageData } from './$types'

  export let data: PageData

  $: pager = new Pager($page.url, { part: 1, type: 'mt', mode: 'auto' })

  $: ztime = data.cinfo.mtime
  $: zsize = data.rdata.sizes[data.cpart]

  // let error = ''
  let l_idx = -1
</script>

<article class="article island" style:--textlh="{$config.textlh}%">
  <header class="head">
    {#each main_tabs as { type, icon, text }}
      <a
        href={pager.gen_url({ type, mode: '', part: data.part })}
        class="htab"
        class:_active={data.rtype == type}>
        <SIcon name={icon} />
        <span>{text}</span>
      </a>
    {/each}
  </header>

  <section class="mode-nav">
    <nav class="chip-list">
      {#if data.rtype == 'mt'}
        <span class="chip-text">Cách dịch:</span>
        {#each mt_mode_tabs as { mode, text, desc }}
          <a
            href={pager.gen_url({ type: 'mt', mode, part: data.part })}
            class="chip-link"
            class:_active={data.rmode == mode}
            data-tip={desc}>
            <span>{text}</span>
          </a>
        {/each}
      {/if}
    </nav>

    <section class="chap-stat">
      <div class="stat-group">
        <span class="stat-entry" data-tip="Số ký tự tiếng Trung">
          <SIcon name="file-analytics" />
          <span class="stat-value">{zsize}</span>
          <span class="stat-label"> chữ</span>
        </span>

        <span class="stat-entry" data-tip="Thời gian lưu văn bản gốc">
          <SIcon name="file-download" />
          <span class="stat-value">{rel_time(ztime)}</span>
        </span>
      </div>
    </section>
  </section>

  <div class="content">
    <div class="reader app-fs-{$config.ftsize} app-ff-{$config.ftface}">
      {#each data.lines as line, _idx}
        <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <svelte:element
          this={_idx > 0 ? 'p' : 'h1'}
          id="L{_idx}"
          class="cdata"
          class:focus={_idx == l_idx}
          on:click={() => (l_idx = _idx)}>
          {@html render_cdata(line, 1)}
        </svelte:element>
      {/each}
    </div>
  </div>
</article>

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

  .cdata {
    cursor: pointer;
    @include bp-min(tl) {
      @include padding-x(var(--gutter));
    }
  }

  .reader {
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
    @include border(--bd-soft, $loc: bottom);
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
</style>
