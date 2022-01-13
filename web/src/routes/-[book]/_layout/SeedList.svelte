<script context="module">
  import { page } from '$app/stores'
  const icon_types = ['affiliate', 'archive', 'archive', 'cloud']
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let sname = ''
  export let pgidx = 0
  export let center = false

  $: nvinfo = $page.stuff.nvinfo || {}
  $: chseed = $page.stuff.chseed || []

  let show_less = true

  function chap_url(sname, pgidx = 0) {
    const url = `/-${nvinfo.bslug}/-${sname}`
    return pgidx > 1 ? url + `?page=${pgidx}` : url
  }

  $: snames = chseed.map((x) => x.sname) || []
  $: hidden_seeds = calculate_hidden_seeds(snames, sname)

  function calculate_hidden_seeds(snames, sname) {
    if (snames.length < 4) return 0
    if (snames.slice(0, 4).includes(sname)) return snames.length - 4
    return snames.length - 3
  }
</script>

<seed-list class:center>
  {#each chseed as zhbook, idx}
    <a
      class="seed-name"
      class:_hidden={zhbook.sname != 'users' && idx >= 3 && show_less}
      class:_active={zhbook.sname == sname}
      href={chap_url(zhbook.sname, pgidx)}>
      <seed-label>
        <span>{zhbook.sname}</span>
        <SIcon name={icon_types[zhbook._type]} />
      </seed-label>
      <seed-stats><strong>{zhbook.chaps}</strong> chương</seed-stats>
    </a>
  {/each}

  {#if show_less && hidden_seeds > 0}
    <button class="seed-name _btn" on:click={() => (show_less = false)}>
      <seed-label><SIcon name="dots" /></seed-label>
      <seed-stats>({hidden_seeds})</seed-stats>
    </button>
  {/if}

  {#if !snames.includes('users')}
    <a
      class="seed-name"
      class:_active={sname === 'users'}
      href={chap_url('users', 0)}>
      <seed-label>
        <span>users</span>
        <SIcon name="archive" />
      </seed-label>
      <seed-stats><strong>0</strong> chương</seed-stats>
    </a>
  {/if}
</seed-list>

<style lang="scss">
  seed-list {
    @include flex($gap: 0.375rem);
    flex-wrap: wrap;

    &.center {
      justify-content: center;
      margin-top: 1rem;
      margin-bottom: 1rem;
    }
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
