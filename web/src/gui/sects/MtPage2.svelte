<script context="module" lang="ts">
  const algos = {
    hmeg: 'Ernie Gram',
    hmeb: 'Electra Base',
    hmes: 'Electra Small',
  }
</script>

<script lang="ts">
  import { config, vdict, zfrom } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import MtData from '$lib/mt_data'

  import Zhline from './MtPage/Zhline.svelte'
  import Cvline from './MtPage/Cvline2.svelte'

  interface Data {
    ztext: string

    mtl_1: string
    txt_2: string

    cdata: string
    _algo: string
  }
  export let data: Data

  let l_focus = 0

  $: ztext = data.ztext.trim().split('\n')
  $: cdata = data.cdata.trim().split('\n')

  $: mtl_1 = MtData.parse_lines(data.mtl_1)
  $: txt_2 = data.txt_2.trim().split('\n')

  $: zen_mode = $config.r_mode == 1
</script>

<article
  class="article island reader app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  style:--textlh="{$config.textlh}%">
  <header>
    <span class="stats" data-tip="Thuật toán phân tích">
      <span class="stats-label">Thuật toán:</span>
      <span class="stats-value _caps">{algos[data._algo] || 'N/A'}</span>
    </span>

    <div class="header-right">
      <span class="stats" data-tip="Số ký tự tiếng Trung">
        <SIcon name="file-analytics" />
        <span class="stats-value">{data.ztext.length}</span>
        <span class="stats-label"> chữ</span>
      </span>
    </div>
  </header>

  <section>
    {#each ztext as input, index (index)}
      <svelte:element
        this={index > 0 || $$props.no_title ? 'p' : 'h1'}
        id="L{index}"
        class="cv-line"
        class:focus={index == l_focus}
        class:debug={$config.r_mode == 2}
        role="tooltip">
        {#if $config.show_z}<Zhline ztext={input} plain={zen_mode} />{/if}
        {#if $config.show_c}<div class="cdata">{cdata[index]}</div>{/if}
        <Cvline input={mtl_1[index]} plain={zen_mode} />
        {#if $config.view_dual}<div class="txt_2">{txt_2[index]}</div>{/if}
      </svelte:element>
    {/each}
  </section>

  <slot name="footer" />
</article>

<div hidden>
  <button data-kbd="f" on:click={() => config.set_r_mode(1)}>Z</button>
  <button data-kbd="d" on:click={() => config.set_r_mode(2)}>D</button>
  <button data-kbd="z" on:click={() => config.toggle('show_z')}>A</button>
  <button data-kbd="c" on:click={() => config.toggle('show_c')}>Q</button>
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

  .cdata {
    @include fgcolor(tert);
    font-size: 1rem;
    line-height: 1.4;
    margin-bottom: 0.25rem;
  }

  .txt_2 {
    @include fgcolor(teal);
    font-size: 0.85em;
    line-height: 1.4;
    margin-top: 0.25rem;
    font-style: italic;
  }

  .stats {
    display: inline-flex;
    align-items: center;

    @include ftsize(sm);
    @include fgcolor(mute);
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
    margin-left: 0.125rem;
    &._caps {
      text-transform: uppercase;
      font-size: 0.85em;
    }
  }
</style>
