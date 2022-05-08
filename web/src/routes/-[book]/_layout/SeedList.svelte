<script context="module" lang="ts">
  import { page } from '$app/stores'
  import { seed_url } from '$utils/route_utils'

  const icon_types = ['affiliate', 'archive', 'cloud-off', 'cloud-fog', 'cloud']
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvinfo = $page.stuff.nvinfo
  export let nvseed = $page.stuff.nvseed || []
  export let chseed: CV.Chseed
  export let pgidx = 1

  $: snames = nvseed.map((x) => x.sname) || []
  $: hidden_seeds = calculate_hidden_seeds(snames, chseed.sname)

  let show_less = true

  function calculate_hidden_seeds(snames: string[], sname: string, size = 4) {
    if (snames.length < size) return 0
    if (snames.slice(0, size).includes(sname)) return snames.length - size
    return snames.length - size + 1
  }
</script>

<seed-list>
  {#each nvseed as { sname, chaps, stype }, idx}
    <a
      href={seed_url(nvinfo.bslug, sname, pgidx)}
      class="seed-name"
      class:_hidden={sname != 'users' && idx >= 4 && show_less}
      class:_active={sname == chseed.sname}
      rel={sname != 'union' ? 'nofollow' : ''}>
      <seed-label>
        <span>{sname}</span>
        <SIcon name={icon_types[stype]} />
      </seed-label>
      <seed-stats><strong>{chaps}</strong> chương</seed-stats>
    </a>
  {/each}

  {#if show_less && hidden_seeds > 0}
    <button class="seed-name _btn" on:click={() => (show_less = false)}>
      <seed-label><SIcon name="dots" /></seed-label>
      <seed-stats>({hidden_seeds})</seed-stats>
    </button>
  {/if}
</seed-list>

<style lang="scss">
  seed-list {
    @include flex-cx($gap: 0.375rem);
    flex-wrap: wrap;
    padding: 0.75rem var(--gutter);
  }

  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .seed-name {
    display: inline-block;
    align-items: center;
    flex-direction: column;
    padding: 0.375em;
    @include bdradi();
    @include linesd(--bd-main);

    &._btn {
      background-color: transparent;
      padding-left: 0.75rem !important;
      padding-right: 0.75rem !important;
    }

    &._hidden {
      display: none;
    }

    &._active {
      display: inline-block;
      @include linesd(primary, 5, $ndef: true);
    }

    // prettier-ignore
    &._active, &:hover, &:active {
      > seed-label { @include fgcolor(primary, 5); }
    }
  }

  seed-label {
    @include flex($center: both);
    @include label();

    line-height: 1rem;
    font-size: rem(13px);

    :global(svg) {
      width: 1rem;
      height: 1rem;
    }

    span {
      margin-right: 0.125em;
    }
  }

  seed-stats {
    display: block;
    text-align: center;
    @include fgcolor(tert);
    font-size: rem(12px);
    line-height: 100%;
  }
</style>
