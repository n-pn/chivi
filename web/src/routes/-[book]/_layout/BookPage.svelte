<script>
  import SIcon from '$atoms/SIcon.svelte'
  import RTime from '$atoms/RTime.svelte'
  import BCover from '$atoms/BCover.svelte'
  import Vessel from '$sects/Vessel.svelte'

  import SeedList from './SeedList.svelte'
  import BookHeader from './BookHeader.svelte'

  export let cvbook
  export let ubmemo
  export let nvtab = 'index'
</script>

<BookHeader {cvbook} {ubmemo} />

<Vessel>
  <div class="main-info">
    <div class="title">
      <h1 class="bname _main">
        <bname-vi>{cvbook.vtitle}</bname-vi>
        <bname-sep>/</bname-sep>
        <bname-zh>{cvbook.ztitle}</bname-zh>
        {#if cvbook.vtitle != cvbook.htitle}
          <bname-sep>/</bname-sep>
          <bname-vi>{cvbook.htitle}</bname-vi>
        {/if}
      </h1>
    </div>

    <div class="cover">
      <BCover bcover={cvbook.bcover} />
    </div>

    <div class="line">
      <span class="stat -trim">
        <SIcon name="edit" />
        <a
          class="link"
          href="/search?t=author&q={encodeURIComponent(cvbook.vauthor)}">
          <span class="label">{cvbook.vauthor}</span>
        </a>
      </span>

      <div class="bgenres">
        {#each cvbook.genres as genre, idx}
          <span class="stat _genre" class:_trim={idx > 1}>
            <a class="link" href="/?genre={genre}">
              <SIcon name="book" />
              <span class="label">{genre}</span>
            </a>
          </span>
        {/each}
      </div>
    </div>

    <div class="line">
      <span class="stat _status">
        <SIcon name="activity" />
        <span>{cvbook.status}</span>
      </span>

      <span class="stat _mftime">
        <SIcon name="clock" />
        <span><RTime mtime={cvbook.mftime} /></span>
      </span>
    </div>

    <div class="line">
      <span class="stat">
        <span>Đánh giá: </span><span class="label"
          >{cvbook.voters <= 10 ? '--' : cvbook.rating}</span
        >/10</span>
      <span class="stat"
        >({cvbook.voters} lượt<span class="trim">&nbsp;đánh giá</span>)</span>
    </div>

    {#if cvbook.yousuu_id || cvbook.root_link}
      <div class="line">
        <span class="stat">Liên kết:</span>

        {#if cvbook.root_link != ''}
          <a
            class="stat link _outer"
            href={cvbook.root_link}
            rel="noopener noreferer"
            target="_blank"
            title="Trang nguồn">
            <span>{cvbook.root_name}</span>
          </a>
        {/if}

        {#if cvbook.yousuu_id != ''}
          <a
            class="stat link _outer"
            href="https://www.yousuu.com/book/{cvbook.yousuu_id}"
            rel="noopener noreferer"
            target="_blank"
            title="Đánh giá">
            <span>yousuu</span>
          </a>
        {/if}
      </div>
    {/if}

    <div class="line _chap">
      <div class="label _chap">Chương tiết:</div>
      <SeedList {cvbook} />
    </div>
  </div>

  <book-section>
    <header class="section-header">
      <a
        href="/-{cvbook.bslug}"
        class="header-tab"
        class:_active={nvtab == 'index'}>
        <span>Tổng quan</span>
      </a>

      <a
        href="/-{cvbook.bslug}/crits"
        class="header-tab"
        class:_active={nvtab == 'crits'}>
        <span>Đánh giá</span>
      </a>

      <a
        href="/-{cvbook.bslug}/board"
        class="header-tab"
        class:_active={nvtab == 'board'}>
        <span>Thảo luận</span>
      </a>
    </header>

    <div class="section-content">
      <slot />
    </div>
  </book-section>
</Vessel>

<style lang="scss">
  .main-info {
    margin: var(--gutter) 0;
    @include flow();
  }

  .title {
    margin-bottom: var(--gutter);

    @include bps(float, left, $pl: right);
    @include bps(width, 100%, $pl: 70%, $ts: 75%);
    @include bps(padding-left, 0, $pl: var(--gutter));
  }

  .bname {
    @include fgcolor(secd);
    font-weight: 400;
    @include clamp($lines: 2);
    // prettier-ignore
    @include bps( font-size, rem(21px), rem(22px), rem(23px), rem(25px), rem(27px) );
    @include bps(line-height, 1.5rem, $pl: 1.75rem, $ts: 2rem);
  }

  bname-sep {
    @include fgcolor(mute);
    font-size: 0.85em;
    vertical-align: top;
  }

  bname-zh {
    font-size: 0.85em;
    vertical-align: top;
    // @include bps(line-height, 1.25rem, $pl: 1.5rem, $ts: 1.75rem);
  }

  // .genre {
  //   display: inline-block;
  //   @include bdradi();
  //   @include bgcolor(primary, 5);
  //   color: #fff;
  //   text-transform: uppercase;
  //   @include bps(font-size, rem(12px), $pl: rem(13px), $tm: rem(14px));
  //   line-height: 1.75em;
  //   padding: 0 0.5em;
  //   &:hover {
  //     @include bgcolor(primary, 5);
  //     color: #fff;
  //   }
  // }

  .cover {
    float: left;
    @include bps(width, 40%, $pm: 35%, $pl: 30%, $ts: 25%);
  }

  .line {
    // float: right;
    padding-left: var(--gutter);

    @include bps(width, 60%, $pm: 65%, $pl: 70%, $ts: 75%);

    :global(svg) {
      margin-top: -0.125rem;
    }

    margin-top: var(--gutter-pm);
    @include fgcolor(tert);
    @include flex($wrap: true);

    &._chap {
      @include bps(width, 100%, $tm: 75%);
      @include bps(padding-left, 0, $tm: var(--gutter));
    }
  }

  .stat {
    margin-right: 0.5rem;
  }

  .trim {
    @include bps(display, none, $tm: inline);
  }

  .link {
    // font-weight: 500;
    color: inherit;
    // @include fgcolor(primary, 7);

    &._outer {
      text-transform: capitalize;
    }

    &._outer,
    &:hover {
      @include fgcolor(primary, 6);

      @include tm-dark {
        @include fgcolor(primary, 4);
      }
    }
  }

  .-trim {
    max-width: 100%;
    @include clamp($width: null);
  }

  .label {
    font-weight: 500;
    // @include fgcolor(neutral, 8);
  }

  .label._chap {
    display: block;
    width: 100%;
    // margin-top: var(--gutter-small);
    margin-bottom: 0.25rem;
  }

  book-section {
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

  $section-height: 3rem;
  .section-header {
    display: flex;
    height: $section-height;
    @include border(--bd-main, $loc: bottom);

    @include tm-dark {
      @include bdcolor(neutral, 6);
    }
  }

  .header-tab {
    height: $section-height;
    line-height: $section-height;
    width: 50%;
    font-weight: 500;
    text-align: center;
    text-transform: uppercase;

    @include ftsize(sm);
    @include bp-min(tm) {
      @include ftsize(md);
    }

    @include fgcolor(neutral, 6);

    &._active {
      @include fgcolor(primary, 6);
      @include border(primary, 5, $width: 2px, $loc: bottom);
    }

    @include tm-dark {
      @include fgcolor(neutral, 4);

      &._active {
        @include fgcolor(primary, 4);
      }
    }
  }

  .section-content {
    padding: 0.75rem 0;
    display: block;
    min-height: 50vh;
  }
</style>
