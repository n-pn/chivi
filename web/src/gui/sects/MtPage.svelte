<script context="module" lang="ts">
  import { navigating } from '$app/stores'
  import { config, vdict } from '$lib/stores'
  import MtData from '$lib/mt_data'

  import Mtmenu, { ctrl as mtmenu } from './MtPage/Mtmenu.svelte'

  import Cvline from './MtPage/Cvline.svelte'
  import Zhline from './MtPage/Zhline.svelte'
</script>

<script lang="ts">
  export let cvdata = ''
  export let zhtext: string[] | null = null

  export let on_change = () => {}

  $: [mtdata, zhtext, dname, d_dub, chars, tspan] = parse_data(cvdata, zhtext)
  $: vdict.put(dname, d_dub)

  let article = null

  let l_hover = 0
  let l_focus = 0

  $: if ($navigating) {
    l_focus = 0
    mtmenu.hide()
  }

  function parse_data(
    input: string,
    rawzh?: string[]
  ): [MtData[], string[], string, string, number, number] {
    const [cvdata, stats, zhtext] = input.split('\n$\t$\t$\n')
    const [d_name, d_dub, chars, tspan] = stats.split('\t')

    const mt_data = MtData.parse_lines(cvdata)
    const zh_data = zhtext ? zhtext.split('\n') : rawzh || []

    return [mt_data, zh_data, d_name, d_dub, +chars, +tspan]
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
</script>

<article
  class="article app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  tabindex="-1"
  style="--textlh: {$config.textlh}%"
  on:blur={mtmenu.hide}
  bind:this={article}>
  <header>
    <slot name="header">Dịch nhanh</slot>
  </header>

  <section>
    {#each zhtext as ztext, index (index)}
      <svelte:element
        this={index > 0 || $$props.no_title ? 'p' : 'h1'}
        id="L{index}"
        class="cv-line"
        class:debug={$config.render == 1}
        class:focus={index == l_focus}
        on:mouseenter={() => (l_hover = index)}>
        {#if $config.showzh}<Zhline {ztext} plain={$config.render < 0} />{/if}
        <Cvline
          input={mtdata[index]}
          focus={render_html($config.render, index, l_hover, l_focus)} />
      </svelte:element>
    {:else}
      <slot name="notext" />
    {/each}

    {#if $config.render >= 0}
      <Mtmenu {article} lines={zhtext} bind:l_focus {l_hover} {on_change} />
    {/if}
  </section>

  <slot name="footer" />
</article>

<section class="stats">
  Số ký tự: {chars} - Thời gian dịch: {tspan}ms
</section>

<div hidden>
  <button data-kbd="s" on:click={() => config.toggle('showzh')}>A</button>
  <button data-kbd="z" on:click={() => config.set_render(-1)}>Z</button>
  <button data-kbd="g" on:click={() => config.set_render(1)}>G</button>
</div>

<style lang="scss">
  .article {
    position: relative;
    min-height: 50vh;

    // margin: 0;
    padding: 0;
    padding-bottom: 0.75rem;

    @include fgcolor(secd);
    @include bgcolor(tert);

    :global(.tm-warm) & {
      background-color: #fffbeb;
    }

    :global(cite) {
      font-style: normal;
      font-variant: small-caps;
    }
  }

  .article > header,
  .article > section {
    @include padding-x(var(--gutter));
    @include bp-min(tl) {
      @include padding-x(2rem);
    }
  }

  header {
    @include border(--bd-main, $loc: bottom);
    padding: var(--gutter-pm) 0;
    line-height: 1.25rem;

    // @include flow();
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  // prettier-ignore
  .cv-line {
    display: block;
    margin: 1em 0;
    color: var(--fgcolor, var(--fg-main));

    :global(.app-ff-1) & { font-family: var(--font-sans); }
    :global(.app-ff-2) & { font-family: var(--font-serif); }
    :global(.app-ff-3) & { font-family: Nunito Sans, var(--font-sans); }
    :global(.app-ff-4) & { font-family: Lora, var(--font-serif); }

    // &.focus {
    //   :global(.tm-light) & { @include bgcolor(warning, 2, 1); }
    //   :global(.tm-warm) & { @include bgcolor(warning, 0, 4); }
    //   :global(.tm-dark) & { @include bgcolor(neutral, 8, 9); }
    //   :global(.tm-oled) & { @include bgcolor(neutral, 9, 8); }
    // }
  }

  // prettier-ignore
  :global(h1).cv-line {
    line-height: 1.4em;

    @include bps(font-size, rem(22px), rem(23px), rem(24px), rem(26px), rem(28px));

    :global(.app-fs-1) & {
      @include bps(font-size, rem(21px), rem(22px), rem(23px), rem(25px), rem(27px));
    }

    :global(.app-fs-5) & {
      @include bps(font-size, rem(23px), rem(24px), rem(25px), rem(26px), rem(29px));
    }
  }

  // prettier-ignore
  :global(p).cv-line {
    text-align: justify;
    text-justify: auto;
    line-height: var(--textlh, 160%);

    :global(.app-fs-1) & {
      @include bps(font-size, rem(15px), rem(16px), rem(17px), rem(18px), rem(19px));
    }

    :global(.app-fs-2) & {
      @include bps(font-size, rem(16px), rem(17px), rem(18px), rem(19px), rem(20px));
    }

    :global(.app-fs-3) & {
      @include bps(font-size, rem(17px), rem(18px), rem(19px), rem(20px), rem(21px));
    }

    :global(.app-fs-4) & {
      @include bps(font-size, rem(19px), rem(20px), rem(21px), rem(22px), rem(23px));
    }

    :global(.app-fs-5) & {
      @include bps(font-size, rem(21px), rem(22px), rem(23px), rem(24px), rem(25px));
    }
  }

  .stats {
    text-align: center;
    margin-top: calc(-1 * var(--gutter));
    padding: 0.5rem 0;
    font-style: italic;
    @include fgcolor(tert);
    @include ftsize(sm);
  }
</style>
