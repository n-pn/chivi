<script context="module">
  import { remote_snames } from '$lib/constants.js'

  function is_remote_seed(sname) {
    return remote_snames.includes(sname)
  }
</script>

<script>
  import { session, navigating } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import Chlist from '$parts/Chlist.svelte'
  import BookPage from '../_layout/BookPage.svelte'

  import Mpager, { Pager, navigate } from '$molds/Mpager.svelte'

  export let cvbook
  export let ubmemo
  export let chinfo

  let pagers = {}
  $: pager = get_pager(chinfo.sname)

  function get_pager(sname) {
    return (pagers[sname] ||= new Pager(`/-${cvbook.bslug}/-${sname}`, {
      page: chinfo.pgidx,
    }))
  }

  $: [main_seeds, hide_seeds] = split_chinfo(cvbook, chinfo.sname)
  let show_more = false

  const _navi = { replace: true, scrollto: '#chlist' }

  $: is_remote = is_remote_seed(chinfo.sname)

  function split_chinfo(cvbook, sname) {
    const input = cvbook.snames.filter((x) => x != 'chivi')

    const main = input.slice(0, 3)
    let secd = input.slice(3)

    if (sname == 'chivi') return [main, secd]
    if (main.includes(sname) || !sname || secd.length == 0) return [main, secd]

    secd = [main[2], ...secd.filter((x) => x != sname)]
    main[2] = sname

    return [main, secd]
  }
</script>

<BookPage {cvbook} {ubmemo} nvtab="chaps">
  <div class="source">
    {#each main_seeds as sname}
      <a
        class="seed-name"
        class:_active={chinfo.sname === sname}
        href={get_pager(sname).url({ page: chinfo.pgidx })}
        use:navigate={_navi}>
        <seed-label>
          <span>{sname}</span>
          <SIcon name={is_remote_seed(sname) ? 'cloud' : 'archive'} />
        </seed-label>
        <seed-stats
          ><strong>{cvbook.chseed[sname]?.chaps || 0}</strong> chương</seed-stats>
      </a>
    {/each}

    {#if hide_seeds.length > 0}
      {#if show_more}
        {#each hide_seeds as sname}
          <a
            class="seed-name"
            href={get_pager(sname).url({ page: chinfo.pgidx })}
            use:navigate={_navi}>
            <seed-label>
              <span>{sname}</span>
              <SIcon name={is_remote_seed(sname) ? 'cloud' : 'archive'} />
            </seed-label>
            <seed-stats
              ><strong>{cvbook.chseed[sname]?.chaps || 0}</strong> chương</seed-stats>
          </a>
        {/each}
      {:else}
        <button class="seed-name _btn" on:click={() => (show_more = true)}>
          <seed-label><SIcon name="dots" /></seed-label>
          <seed-stats>({hide_seeds.length})</seed-stats>
        </button>
      {/if}
    {/if}

    <a
      class="seed-name"
      class:_active={chinfo.sname === 'chivi'}
      href={get_pager('chivi').url({ page: chinfo.pgidx })}
      use:navigate={_navi}>
      <seed-label>
        <span>chivi</span>
        <SIcon name="archive" />
      </seed-label>
      <seed-stats
        ><strong>{cvbook.chseed.chivi?.chaps || 0}</strong> chương</seed-stats>
    </a>
  </div>

  <div id="chlist" class="chinfo">
    <div class="-left">
      <span class="-text">{chinfo.sname}</span>
      <span class="-span">{chinfo.total} chương</span>
      <span class="-span"><RTime mtime={chinfo.utime} /></span>
    </div>

    {#if chinfo.sname == 'chivi'}
      <a
        class="m-btn"
        class:_disable={$session.privi < 2}
        href="/-{cvbook.bslug}/-{chinfo.sname}/+new?chidx={chinfo.total + 1}">
        <SIcon name="plus" />
        <span class="-hide">Thêm chương</span>
      </a>
    {:else}
      <a
        class="m-btn"
        href={chinfo.wlink}
        target="_blank"
        rel="noopener noreferer">
        <SIcon name="external-link" />
        <span class="-hide">Nguồn</span>
      </a>
      <a
        class="m-btn"
        class:_disable={!chinfo.crawl}
        href={pager.url({ page: chinfo.pgidx, mode: chinfo.crawl ? 2 : 1 })}
        use:navigate={_navi}>
        {#if $navigating}
          <SIcon name="loader" spin={true} />
        {:else}
          <SIcon name="refresh" />
        {/if}
        <span class="-hide">Đổi mới</span>
      </a>
    {/if}
  </div>

  <div class="chlist">
    {#if chinfo.pgmax > 0}
      <Chlist
        bslug={cvbook.bslug}
        sname={chinfo.sname}
        chaps={chinfo.lasts}
        track={ubmemo}
        {is_remote} />

      <div class="chlist-sep" />

      <Chlist
        bslug={cvbook.bslug}
        sname={chinfo.sname}
        chaps={chinfo.chaps}
        track={ubmemo}
        {is_remote} />

      <footer class="foot">
        <Mpager {pager} pgidx={chinfo.pgidx} pgmax={chinfo.pgmax} {_navi} />
      </footer>
    {:else}
      <p class="empty">Không có nội dung :(</p>
    {/if}
  </div>
</BookPage>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .source {
    @include flex($center: horz, $wrap: wrap, $gap: 0.5rem);
    margin-top: var(--gutter-pm);
  }

  .seed-name {
    display: block;
    // display: flex;
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

    &._active {
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

  .-hide {
    @include bps(display, none, $tm: inline-block);
  }

  .chinfo {
    @include flex($gap: 0.5rem);
    margin: var(--verpad-pm) 0;

    .-left {
      display: flex;
      flex: 1;
      margin: 0.25rem 0;
      line-height: 1.75rem;
      transform: translateX(1px);
      @include bps(font-size, 13px, 14px);
    }

    .-text {
      padding-left: 0.5rem;
      @include label();
      @include fgcolor(tert);
      @include border(primary, 5, $width: 3px, $loc: left);
    }

    .-span {
      font-style: italic;
      @include fgcolor(neutral, 4);

      &:before {
        display: inline-block;
        content: '·';
        text-align: center;
        @include bps(width, 0.5rem, 0.75rem, 1rem);
      }
    }
  }

  .chlist-sep {
    width: 70%;
    margin: var(--gutter-ts) auto;
    @include border(--bd-main, $loc: bottom);
  }

  .empty {
    min-height: 30vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(neutral, 5);
  }

  .foot {
    margin-top: 1rem;
  }
</style>
