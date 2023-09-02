<script context="module" lang="ts">
  import { config, vdict, zfrom } from '$lib/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import MtData from '$lib/mt_data'

  import Zhline from './MtPage/Zhline.svelte'
  import Cvline, { show_mtl } from './MtPage/Cvline.svelte'
</script>

<script lang="ts">
  export let data: { cvmtl: string; ztext: string; cdata: string }

  let l_hover = 0
  let l_focus = 0

  $: [cvmtl] = MtData.parse_cvmtl(data.cvmtl)
  $: ztext = data.ztext.trim().split('\n')
  $: cdata = data.cdata.trim().split('\n')
</script>

<article
  class="article island reader app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  style:--textlh="{$config.textlh}%">
  <header>
    <span class="stats" data-tip="Phiên bản máy dịch">
      <span class="stats-label">Máy dịch:</span>
      <SIcon name="versions" />
      <span class="stats-value">v2</span>
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
      {@const elem = index > 0 || $$props.no_title ? 'p' : 'h1'}
      {@const mtlv1 = cvmtl[index]}
      {@const view_mtl = show_mtl(
        $config.render,
        ztext.length - 1,
        index,
        l_hover,
        l_focus
      )}
      <svelte:element
        this={elem}
        id="L{index}"
        class="cv-line"
        class:focus={index == l_focus}
        on:mouseenter={() => (l_hover = index)}
        role="tooltip">
        {#if $config.showzh}
          <Zhline ztext={input} plain={!view_mtl} />
          <div class="cdata">{cdata[index]}</div>
        {/if}
        <Cvline input={mtlv1} focus={view_mtl} />
      </svelte:element>
    {/each}
  </section>

  <slot name="footer" />
</article>

<div hidden>
  <button data-kbd="s" on:click={() => config.toggle('showzh')}>A</button>
  <button data-kbd="z" on:click={() => config.set_render(-1)}>Z</button>
  <button data-kbd="g" on:click={() => config.set_render(1)}>G</button>
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
</style>
