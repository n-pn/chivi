<script lang="ts">
  import { page } from '$app/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let chmeta: CV.Chmeta
  export let chinfo: CV.Chinfo

  $: nvinfo = $page.stuff.nvinfo
  $: nvseed = $page.stuff.nvseed

  let show_less = true

  function chap_url(sname: string) {
    return `/-${nvinfo.bslug}/-${sname}/-${chinfo.uslug}-${chinfo.chidx}`
  }

  $: snames = nvseed?.map((x) => x.sname) || []
  $: hidden_seeds = calculate_hidden_seeds(snames, chmeta.sname)

  function calculate_hidden_seeds(snames: string[], sname: string) {
    if (snames.length < 5) return 0
    if (snames.slice(0, 5).includes(sname)) return snames.length - 5
    return snames.length - 4
  }
</script>

<chap-seed>
  {#each nvseed as zhbook, idx}
    {#if zhbook.chaps >= chinfo.chidx}
      <a
        class="seed-name"
        class:_hidden={idx > 3 && show_less}
        class:_active={zhbook.sname == chmeta.sname}
        href={chap_url(zhbook.sname)}
        rel={zhbook.sname != 'chivi' ? 'nofollow' : ''}>
        <seed-label>{zhbook.sname}</seed-label>
      </a>
    {/if}
  {/each}

  {#if show_less && hidden_seeds > 0}
    <button class="seed-name _btn" on:click={() => (show_less = false)}>
      <seed-label><SIcon name="dots" /></seed-label>
    </button>
  {/if}
</chap-seed>

<style lang="scss">
  chap-seed {
    @include flex-cx($gap: 0.375rem);
    flex-wrap: wrap;
    padding: 0.5rem var(--gutter);
  }

  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .seed-name {
    padding: 0.375rem;
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
  }
</style>
