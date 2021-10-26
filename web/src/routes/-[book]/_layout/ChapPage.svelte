<script>
  import { session, navigating } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import Chlist from '$parts/Chlist.svelte'
  import BookPage from '../_layout/BookPage.svelte'

  import Mpager, { Pager } from '$molds/Mpager.svelte'

  export let cvbook
  export let ubmemo
  export let chinfo

  let pagers = {}
  $: pager = get_pager(chinfo.sname)

  function get_pager(sname) {
    const page = chinfo.pgidx
    const url = `/-${cvbook.bslug}/-${sname}`
    return (pagers[sname] = pagers[sname] || new Pager(url, { page }))
  }
</script>

<BookPage {cvbook} {ubmemo} nvtab="chaps">
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
        href={pager.url({ page: chinfo.pgidx, mode: chinfo.crawl ? 2 : 1 })}>
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
        is_remote={chinfo._seed} />

      <div class="chlist-sep" />

      <Chlist
        bslug={cvbook.bslug}
        sname={chinfo.sname}
        chaps={chinfo.chaps}
        track={ubmemo}
        is_remote={chinfo._seed} />

      <footer class="foot">
        <Mpager {pager} pgidx={chinfo.pgidx} pgmax={chinfo.pgmax} />
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

  .-hide {
    @include bps(display, none, $tm: inline-block);
  }

  .chinfo {
    @include flex($gap: 0.5rem);
    margin-bottom: var(--gutter-pl);

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
