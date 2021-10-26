<script>
  import { session, navigating } from '$app/stores'

  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import Chlist from '$parts/Chlist.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import SeedList from './SeedList.svelte'
  import BookHeader from './BookHeader.svelte'

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

<BookHeader {cvbook} {ubmemo} />

<Vessel>
  <nav class="bread">
    <a href="/-{cvbook.bslug}" class="crumb _link">{cvbook.vtitle}</a>
    <span>/</span>
    <span class="crumb _text">Chương tiết</span>
  </nav>

  <chap-page>
    <seed-list>
      <SeedList {cvbook} _sname={chinfo.sname} />
    </seed-list>

    <seed-info>
      <info-left>
        <info-text>{chinfo.sname}</info-text>
        <info-span>{chinfo.total} chương</info-span>
        <info-span><RTime mtime={chinfo.utime} /></info-span>
      </info-left>

      <info-right>
        {#if chinfo.sname == 'chivi'}
          <a
            class="m-btn"
            class:_disable={$session.privi < 2}
            href="/-{cvbook.bslug}/-{chinfo.sname}/+new?chidx={chinfo.total +
              1}">
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
            href={pager.url({
              page: chinfo.pgidx,
              mode: chinfo.crawl ? 2 : 1,
            })}>
            {#if $navigating}
              <SIcon name="loader" spin={true} />
            {:else}
              <SIcon name="refresh" />
            {/if}
            <span class="-hide">Đổi mới</span>
          </a>
        {/if}
      </info-right>
    </seed-info>

    <chap-list>
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
    </chap-list>
  </chap-page>
</Vessel>

<style lang="scss">
  @mixin label {
    font-weight: 500;
    text-transform: uppercase;
    @include fgcolor(tert);
  }

  .bread {
    padding: var(--gutter-pl) 0;
    line-height: var(--lh-narrow);

    // @include flow();
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  .crumb {
    // float: left;

    &._link {
      color: inherit;
      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  chap-page {
    @include bgcolor(tert);

    display: block;
    margin: 0 -0.5rem var(--gutter);
    padding: 0 0.5rem;
    border-radius: 0.5rem;

    @include shadow(2);

    @include bp-min(pl) {
      margin-left: 0;
      margin-right: 0;

      padding-left: 1rem;
      padding-right: 1rem;
      border-radius: 1rem;

      @include tm-dark {
        @include linesd(--bd-soft, $ndef: false, $inset: false);
      }
    }
  }

  seed-list {
    @include flex-cx();
    flex-wrap: wrap;
    padding-top: 0.75rem;
    padding-bottom: 0.25rem;
    @include border(--bd-main, $loc: bottom);
  }

  seed-info {
    display: flex;
    padding: 0.75rem 0;
  }

  info-left {
    display: flex;
    flex: 1;
    margin: 0.25rem 0;
    line-height: 1.75rem;
    transform: translateX(1px);
    @include bps(font-size, 13px, 14px);
  }

  .-hide {
    @include bps(display, none, $tm: inline-block);
  }

  info-right {
    @include flex($gap: 0.5rem);
  }

  // .chinfo {
  //   margin-bottom: var(--gutter-pl);
  // }

  info-text {
    padding-left: 0.5rem;
    @include label();
    @include fgcolor(tert);
    @include border(primary, 5, $width: 3px, $loc: left);
  }

  info-span {
    font-style: italic;
    @include fgcolor(neutral, 4);

    &:before {
      display: inline-block;
      content: '·';
      text-align: center;
      @include bps(width, 0.5rem, 0.75rem, 1rem);
    }
  }

  chap-list {
    display: block;
    padding-bottom: 0.75rem;
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
