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
  <SeedList {cvbook} _sname={chinfo.sname} center={true} />

  <chap-page>
    <page-info>
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
            class:_disable={!chinfo._seed}
            href={pager.url({ page: chinfo.pgidx, force: true })}>
            {#if $navigating}
              <SIcon name="loader" spin={true} />
            {:else}
              <SIcon name="refresh" />
            {/if}
            <span class="-hide">Đổi mới</span>
          </a>
        {/if}
      </info-right>
    </page-info>

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

  chap-page {
    display: block;
    margin: 0 -0.5rem var(--gutter);

    @include shadow(2);
    @include bgcolor(tert);

    @include bp-min(pl) {
      margin-left: 0;
      margin-right: 0;
      border-radius: 1rem;
    }

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }

    > * {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  page-info {
    display: flex;
    padding-top: var(--gutter);
    padding-bottom: var(--gutter);
    margin-bottom: var(--gutter);

    // @include bgcolor(main);
    // @include bdradi(1rem, $loc: top);
    @include border(--bd-main, $loc: bottom);
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

  .m-btn {
    background: inherit;

    &:hover {
      @include bgcolor(secd);
    }
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
    margin: var(--gutter) auto;
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
