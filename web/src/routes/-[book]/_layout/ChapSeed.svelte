<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let cvbook
  export let sname = ''
  export let chidx = 1
  export let uslug = 'chuong'
  let show_less = true

  function chap_url(sname) {
    return `/-${cvbook.bslug}/-${sname}/-${uslug}-${chidx}`
  }

  $: hidden_seeds = calculate_hidden_seeds(cvbook.snames, sname)

  function calculate_hidden_seeds(snames, sname) {
    if (snames.length < 5) return 0
    if (snames.slice(0, 5).includes(sname)) return snames.length - 5
    return snames.length - 4
  }
</script>

<chap-seed>
  {#each cvbook.chseed as zhbook, idx}
    <a
      class="seed-name"
      class:_hidden={zhbook.sname != 'chivi' && idx > 3 && show_less}
      class:_active={zhbook.sname == sname}
      href={chap_url(zhbook.sname)}>
      <seed-label>
        <span>{zhbook.sname}</span>
        <SIcon name={zhbook._seed ? 'cloud' : 'archive'} />
      </seed-label>
    </a>
  {/each}

  {#if show_less && hidden_seeds > 0}
    <button class="seed-name _btn" on:click={() => (show_less = false)}>
      <seed-label><SIcon name="dots" /></seed-label>
    </button>
  {/if}

  {#if !cvbook.snames.includes('chivi')}
    <a
      class="seed-name"
      class:_active={sname === 'chivi'}
      href={chap_url('chivi', 0)}>
      <seed-label>
        <span>chivi</span>
        <SIcon name="archive" />
      </seed-label>
    </a>
  {/if}
</chap-seed>

<style lang="scss">
  chap-seed {
    @include flex-cx($gap: 0.375rem);
    margin-top: -0.75rem;
    padding-bottom: 0.75rem;
    @include border(--bd-main, $loc: bottom);
    margin-bottom: var(--verpad);
    font-family: var(--font-sans);
  }

  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .seed-name {
    padding: 0.5em;
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
</style>
