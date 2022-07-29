<script context="module" lang="ts">
  import { config, vdict } from '$lib/stores'

  import { SIcon } from '$gui'
  import MtData from '$lib/mt_data'

  import Mtmenu, { ctrl as mtmenu } from './MtPage/Mtmenu.svelte'

  import Cvline from './MtPage/Cvline.svelte'
  import Zhline from './MtPage/Zhline.svelte'
  import { rel_time } from '$utils/time_utils'
  import { beforeNavigate } from '$app/navigation'
</script>

<script lang="ts">
  export let cvdata = ''
  export let on_change = () => {}

  export let mftime = 0
  export let mficon = 'file-download'
  export let source = ''

  let mtdata = []
  let zhtext = []
  let cached = false // reloading chapter do not need zhtext anymore

  $: [chars, tspan, dsize] = parse_data(cvdata)

  let article = null
  let l_hover = 0
  let l_focus = 0

  beforeNavigate(() => {
    l_focus = 0
    cached = false
    mtmenu.hide()
  })

  function parse_data(input: string) {
    const [cvdata, stats = '', rawtxt] = input.split('\n$\t$\t$\n')

    mtdata = MtData.parse_lines(cvdata)
    if (rawtxt) {
      cached = true
      zhtext = rawtxt.split('\n')
    } else if (!cached) {
      zhtext = []
    }

    const [dname, d_dub, chars = '', tspan = '', dsize = ''] = stats.split('\t')
    if (dname) vdict.put(dname, d_dub)
    return [+chars, +tspan, +dsize]
  }

  function render_html(
    render: number,
    index: number,
    hover: number,
    focus: number
  ) {
    if (render != 0) return render > 0
    if (index == hover) return true

    if (index > focus - 3 && index < focus + 3) return true
    if (focus == 0) return index == zhtext.length - 1
    return index == 0 && focus == zhtext.length - 1
  }

  function change_engine(engine: number) {
    config.set_engine(engine)
    on_change()
  }
</script>

<article
  class="article app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  tabindex="-1"
  style="--textlh: {$config.textlh}%"
  on:blur={mtmenu.hide}
  bind:this={article}>
  <header>
    <span class="stats" data-tip="Phiên bản máy dịch">
      <span class="stats-label">Máy dịch:</span>
      <SIcon name="versions" />
      <span class="stats-value">v{$config.engine || 1}</span>
    </span>

    <span class="stats" data-tip="Thời gian chạy máy dịch">
      <span class="stats-label">Thời gian dịch:</span>
      <SIcon name="clock" />
      <span class="stats-value">{tspan}ms</span>
    </span>
    <span class="stats _dname" data-tip="Từ điển bộ truyện">
      <span class="stats-label">Từ điển riêng:</span>
      <SIcon name="package" />
      <a href="/dicts/{$vdict.dname}" class="stats-value _link">{dsize} từ</a>
    </span>

    <div class="header-right">
      {#if mftime > 0}
        <span class="stats" data-tip="Thời gian lưu văn bản gốc">
          <SIcon name={mficon} />
          <span class="stats-value"
            >{rel_time(mftime).replace(' trước', ' tr.')}</span>
        </span>
      {/if}

      <span class="stats" data-tip="Số ký tự tiếng Trung">
        <SIcon name="file-analytics" />
        <span class="stats-value">{chars}</span>
        <span class="stats-label"> chữ</span>
      </span>

      {#if source && source != '/'}
        <a
          class="stats"
          href={source}
          rel="noopener noreferrer nofollow"
          target="_blank">
          <SIcon name="external-link" />
        </a>
      {/if}
    </div>
  </header>

  {#each mtdata as input, index (index)}
    <svelte:element
      this={index > 0 || $$props.no_title ? 'p' : 'h1'}
      id="L{index}"
      class="cv-line"
      class:debug={$config.render == 1}
      class:focus={index == l_focus}
      on:mouseenter={() => (l_hover = index)}>
      {#if $config.showzh}
        <Zhline ztext={zhtext[index]} plain={$config.render < 0} />
      {/if}
      <Cvline
        {input}
        focus={render_html($config.render, index, l_hover, l_focus)} />
    </svelte:element>
  {:else}
    <slot name="notext" />
  {/each}

  {#if $config.render >= 0}
    <Mtmenu {article} lines={zhtext} bind:l_focus {l_hover} {on_change} />
  {/if}

  <slot name="footer" />
</article>

<div hidden>
  <button data-kbd="s" on:click={() => config.toggle('showzh')}>A</button>
  <button data-kbd="z" on:click={() => config.set_render(-1)}>Z</button>
  <button data-kbd="g" on:click={() => config.set_render(1)}>G</button>
  <button data-kbd="⌃1" on:click={() => change_engine(1)}>1</button>
  <button data-kbd="⌃2" on:click={() => change_engine(2)}>2</button>
</div>

<style lang="scss">
  .article {
    position: relative;
    min-height: 30vh;

    // margin: 0;
    padding: 0;
    padding-bottom: 0.75rem;

    @include fgcolor(secd);
    @include bgcolor(tert);

    :global(.tm-warm) & {
      background-color: #fffbeb;
    }

    @include bps(
      --head-fs,
      rem(22px),
      rem(23px),
      rem(24px),
      rem(26px),
      rem(28px)
    );

    &.app-fs-1 {
      @include bps(
        --para-fs,
        rem(15px),
        rem(16px),
        rem(17px),
        rem(18px),
        rem(19px)
      );

      @include bps(
        --head-fs,
        rem(21px),
        rem(22px),
        rem(23px),
        rem(25px),
        rem(27px)
      );
    }

    &.app-fs-2 {
      @include bps(
        --para-fs,
        rem(16px),
        rem(17px),
        rem(18px),
        rem(19px),
        rem(20px)
      );
    }

    &.app-fs-3 {
      @include bps(
        --para-fs,
        rem(17px),
        rem(18px),
        rem(19px),
        rem(20px),
        rem(21px)
      );
    }

    &.app-fs-4 {
      @include bps(
        --para-fs,
        rem(19px),
        rem(20px),
        rem(21px),
        rem(22px),
        rem(23px)
      );
    }

    &.app-fs-5 {
      @include bps(
        --para-fs,
        rem(21px),
        rem(22px),
        rem(23px),
        rem(24px),
        rem(25px)
      );

      @include bps(
        --head-fs,
        rem(23px),
        rem(24px),
        rem(25px),
        rem(26px),
        rem(29px)
      );
    }

    :global(cite) {
      font-style: normal;
      font-variant: small-caps;
    }

    & > header,
    & .cv-line {
      @include padding-x(var(--gutter));

      @include bp-min(tl) {
        @include padding-x(2rem);
      }
    }
  }

  header {
    display: flex;
    padding: var(--gutter-pm) 0;
    line-height: 1.25rem;

    // @include flow();
    @include ftsize(sm);
    // @include fgcolor(secd);
    @include border(--bd-soft, $loc: bottom);
  }

  .header-right {
    display: flex;
    margin-left: auto;
    padding-left: 0.25rem;
  }

  .cv-line {
    display: block;

    color: var(--fgcolor, var(--fg-main));

    :global(.app-ff-1) & {
      font-family: var(--font-sans);
    }
    :global(.app-ff-2) & {
      font-family: var(--font-serif);
    }
    :global(.app-ff-3) & {
      font-family: Nunito Sans, var(--font-sans);
    }
    :global(.app-ff-4) & {
      font-family: Lora, var(--font-serif);
    }

    // &.focus {
    //   :global(.tm-light) & { @include bgcolor(warning, 2, 1); }
    //   :global(.tm-warm) & { @include bgcolor(warning, 0, 4); }
    //   :global(.tm-dark) & { @include bgcolor(neutral, 8, 9); }
    //   :global(.tm-oled) & { @include bgcolor(neutral, 9, 8); }
    // }
  }

  :global(h1).cv-line {
    line-height: 1.4em;
    margin: 1em 0;
    font-size: var(--head-fs);
  }

  :global(p).cv-line {
    margin: 1em 0;
    text-align: justify;
    text-justify: auto;
    line-height: var(--textlh, 160%);
    font-size: var(--para-fs);
  }

  .stats {
    display: inline-flex;
    align-items: center;

    @include ftsize(sm);
    @include fgcolor(mute);

    & + &:before {
      content: ' ';
      margin: 0 0.25rem;
    }
  }

  .stats-label {
    display: none;
    // font-style: italic;

    @include bp-min(ts) {
      display: inline-block;

      .stats-value + & {
        margin-left: 0.125rem;
      }
      & + :global(svg) {
        display: none;
      }
    }
  }

  .stats-value {
    font-style: normal;
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
