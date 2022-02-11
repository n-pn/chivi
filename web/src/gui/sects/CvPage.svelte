<script context="module">
  import { browser } from '$app/env'
  import { navigating, session } from '$app/stores'
  import { config } from '$lib/stores'
  import { vdict } from '$lib/stores'
  import CvData from '$lib/cv_data'

  import Cvmenu, { ctrl as cvmenu } from './CvPage/Cvmenu.svelte'

  import Aditem from '$molds/Aditem.svelte'
  import Cvline from '$sects/Cvline.svelte'
  import Zhline from './CvPage/Zhline.svelte'
</script>

<script>
  export let cvdata = ''
  export let zhtext = []

  export let dname = 'combine'
  export let d_dub = 'Tổng hợp'

  export let on_change = () => {}

  $: cv_lines = CvData.parse_lines(cvdata)
  $: vdict.put(dname, d_dub)

  let article = null

  let l_hover = 0
  let l_focus = 0

  $: if ($navigating) {
    l_focus = 0
    cvmenu.hide()
  }

  function render_html(render, index, hover, focus) {
    if (render != 0) return render > 0
    if (index == hover) return true

    if (index > focus - 3 && index < focus + 3) return true
    if (focus == 0) return index == zhtext.length - 1
    return index == 0 && focus == zhtext.length - 1
  }

  $: ads_offset = (zhtext.length % 3) + 3 // offset ads placement
  let ads_blocks = 8 // show as after this number of lines
  $: {
    const lines = Math.floor(zhtext.length / 7) // only show max 8 ads
    ads_blocks = lines < 8 ? 8 : lines // show less ads if chapter is short
  }
</script>

<article
  tabindex="-1"
  style="--textlh: {$config.textlh}%"
  on:blur={cvmenu.hide}
  bind:this={article}>
  <header>
    <slot name="header">Dịch nhanh</slot>
  </header>

  {#each zhtext as ztext, index (index)}
    {#if browser && $session.privi < 2 && index % ads_blocks == ads_offset}
      <Aditem type="article" />
    {/if}

    <cv-data
      id="L{index}"
      class:debug={$config.render == 1}
      class:focus={index == l_focus}
      on:mouseenter={() => (l_hover = index)}>
      {#if $config.showzh}<Zhline {ztext} plain={$config.render < 0} />{/if}
      <Cvline
        input={cv_lines[index]}
        focus={render_html($config.render, index, l_hover, l_focus)} />
    </cv-data>
  {/each}

  {#if $config.render >= 0}
    <Cvmenu {article} lines={zhtext} bind:l_focus {l_hover} {on_change} />
  {/if}
</article>

<div hidden>
  <button data-kbd="s" on:click={() => config.toggle('showzh')}>A</button>
  <button data-kbd="z" on:click={() => config.set_render(-1)}>Z</button>
  <button data-kbd="g" on:click={() => config.set_render(1)}>G</button>
</div>

<style lang="scss">
  article {
    position: relative;
    min-height: 50vh;
    padding: 0 var(--gutter) var(--verpad);

    @include fgcolor(secd);
    @include bgcolor(tert);
    @include shadow(1);

    @include bp-min(tl) {
      margin: 0 var(--gutter);
      @include bdradi();
      @include tm-dark {
        @include linesd(--bd-soft, $ndef: false, $inset: false);
      }
    }

    :global(.tm-warm) & {
      background: #fffbeb;
    }

    :global(cite) {
      font-style: normal;
      font-variant: small-caps;
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
  cv-data {
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
  cv-data:first-of-type {
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
  cv-data:not(:first-of-type) {
    text-align: justify;
    text-justify: auto;
    line-height: var(--textlh, 160%);

    :global(.app-fs-1) & {
      @include bps(font-size, rem(15px), rem(16px), rem(17px), rem(18px), rem(19px));
    }

    :global(.app-fs-2) & {
      @include bps(font-size, rem(16px), rem(17px), rem(18px), rem(10px), rem(20px));
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

  :global {
    .crumb {
      // float: left;

      &._link {
        color: inherit;
        &:hover {
          @include fgcolor(primary, 5);
        }
      }
    }
  }
</style>
