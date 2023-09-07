<script context="module" lang="ts">
  const algos = {
    hmeg: 'Ernie Gram',
    hmeb: 'Electra Base',
    hmes: 'Electra Small',
  }
</script>

<script lang="ts">
  import { config } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { type Cdata, render_cdata } from '$lib/mt_data_2'

  export let data: { cdata: Array<Cdata>; _algo: string }

  let l_focus = 0
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
  </header>

  <section>
    {#each data.cdata as cdata, index}
      <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
      <svelte:element
        this={index > 0 || $$props.no_title ? 'p' : 'h1'}
        id="L{index}"
        class="cv-line"
        class:focus={index == l_focus}
        class:debug={$config.r_mode == 2}
        on:mouseenter={() => (l_focus = index)}
        role="tooltip">
        {@html render_cdata(cdata, zen_mode || index != l_focus)}
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
