<script>
  import SIcon from '$atoms/SIcon.svelte'
  import { snames } from '$lib/constants'

  export let cvbook
  export let _sname = ''
  export let pgidx = 0
  let show_less = true

  function chap_url(sname, pgidx = 0) {
    const url = `/-${cvbook.bslug}/-${sname}`
    return pgidx > 1 ? url + `?page=${pgidx}` : url
  }

  $: hidden_seeds = calculate_hidden_seeds(cvbook.snames, _sname)

  function calculate_hidden_seeds(snames, _sname) {
    if (snames.length < 5) return 0
    if (snames.slice(0, 5).includes(_sname)) return snames.length - 5
    return snames.length - 4
  }
</script>

{#each cvbook.chseed as zhbook, idx}
  <a
    class="seed-name"
    class:_hidden={zhbook.sname != 'chivi' && idx > 3 && show_less}
    class:_active={zhbook.sname == _sname}
    href={chap_url(zhbook.sname, pgidx)}>
    <seed-label>
      <span>{zhbook.sname}</span>
      <SIcon name={zhbook._seed ? 'cloud' : 'archive'} />
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

{#if !cvbook.snames.includes('chivi')}
  <a
    class="seed-name"
    class:_active={_sname === 'chivi'}
    href={chap_url('chivi', 0)}>
    <seed-label>
      <span>chivi</span>
      <SIcon name="archive" />
    </seed-label>
    <seed-stats><strong>0</strong> chương</seed-stats>
  </a>
{/if}

<style lang="scss">
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

    margin-right: 0.375rem;
    margin-bottom: 0.375rem;

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
