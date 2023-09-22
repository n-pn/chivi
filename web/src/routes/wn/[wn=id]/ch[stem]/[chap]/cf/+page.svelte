<script lang="ts">
  import { config } from '$lib/stores'
  import { rel_time } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import Zhline from '$gui/sects/MtPage/Zhline.svelte'
  // import LineEdit from '$gui/sects/MtPage/LineEdit.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ztext, btran } = data)
  $: c_len = ztext.reduce((a, i) => a + i.length, 0)
</script>

<article
  class="article island reader app-fs-{$config.ftsize} app-ff-{$config.ftface}"
  style:--textlh="{$config.textlh}%">
  <header>
    <span class="stats" data-tip="Dịch chương tiết dựa theo máy dịch của Bing">
      <span class="stats-label">Máy dịch:</span>
      <span class="stats-value">Bing</span>
    </span>

    <div class="header-right">
      <span
        class="stats"
        data-tip="Mốc thời điểm chương tiết được dịch từ Bing">
        <SIcon name="clock" />
        <span class="stats-value">{rel_time(data.mtime)}</span>
      </span>

      <span class="stats" data-tip="Số ký tự tiếng Trung">
        <SIcon name="file-analytics" />
        <span class="stats-value">{c_len}</span>
        <span class="stats-label"> chữ</span>
      </span>
    </div>
  </header>

  <section>
    {#each ztext as input, index (index)}
      {@const elem = index > 0 || $$props.no_title ? 'p' : 'h1'}
      <svelte:element this={elem} id="L{index}" class="cv-line">
        {#if $config.showzh}<Zhline ztext={input} plain={false} />{/if}
        <cv-line>{btran[index]}</cv-line>
      </svelte:element>
    {/each}
  </section>

  <slot name="footer" />
</article>

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

  .v2 {
    // margin-top: -1rem;
    @include fgcolor(teal, 6);
  }
</style>
