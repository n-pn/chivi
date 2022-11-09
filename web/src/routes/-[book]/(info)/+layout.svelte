<script lang="ts">
  import { page } from '$app/stores'
  import { session } from '$lib/stores'

  import { SIcon, BCover } from '$gui'
  import { map_status } from '$utils/nvinfo_utils'

  import RTime from '$gui/atoms/RTime.svelte'
  import BookTrack from '$gui/parts/BookTrack.svelte'

  $: nvinfo = $page.data.nvinfo
  $: nv_tab = map_tab_from_route($page.route.id || '')

  function map_tab_from_route(route_id: string) {
    if (route_id.includes('crits')) return 'crits'
    if (route_id.includes('chaps')) return 'chaps'
    return 'index'
  }
</script>

<div class="main-info">
  <div class="title">
    <h1 class="bname _main">
      <bname-vi>{nvinfo.btitle_vi}</bname-vi>
      {#if nvinfo.btitle_zh != nvinfo.btitle_vi}
        <bname-sep>/</bname-sep>
        <bname-zh>{nvinfo.btitle_zh}</bname-zh>
      {/if}
      {#if nvinfo.btitle_hv != nvinfo.btitle_vi && nvinfo.btitle_hv != nvinfo.btitle_zh}
        <bname-sep>/</bname-sep>
        <bname-vi>{nvinfo.btitle_hv}</bname-vi>
      {/if}
    </h1>
  </div>

  <div class="cover">
    <BCover bcover={nvinfo.bcover} scover={nvinfo.scover} />
  </div>

  <div class="line">
    <span class="stat -trim">
      <SIcon name="edit" />
      <a class="link" href="/books/={nvinfo.author_vi}">
        <span class="label">{nvinfo.author_vi}</span>
      </a>
    </span>

    <div class="bgenres">
      {#each nvinfo.genres || [] as genre, idx}
        <span class="stat _genre" class:_trim={idx > 1}>
          <a class="link" href="/books/-{genre}">
            <SIcon name="folder" />
            <span class="label">{genre}</span>
          </a>
        </span>
      {/each}
    </div>
  </div>

  <div class="line">
    <span class="stat _status">
      <SIcon name="activity" />
      <span>{map_status(nvinfo.status)}</span>
    </span>

    <span class="stat _mftime">
      <SIcon name="clock" />
      <span><RTime mtime={nvinfo.mftime} /></span>
    </span>
  </div>

  <div class="line">
    <span class="stat">
      <span>Đánh giá: </span><span class="label"
        >{nvinfo.voters <= 10 ? '--' : nvinfo.rating}</span
      >/10</span>
    <span class="stat"
      >({nvinfo.voters} lượt<span class="trim">&nbsp;đánh giá</span>)</span>
  </div>

  {#if nvinfo.ys_snvid || nvinfo.pub_link}
    <div class="line">
      <span class="stat">Liên kết:</span>

      {#if nvinfo.ys_snvid != ''}
        <a
          class="stat link _outer"
          href="https://www.yousuu.com/book/{nvinfo.ys_snvid}"
          rel="noopener noreferrer"
          target="_blank"
          data-tip="Đánh giá tiếng Trung">
          <span>yousuu</span>
        </a>

        <a
          class="stat link _outer"
          href={nvinfo.pub_link}
          rel="noopener noreferrer"
          target="_blank"
          data-tip="Trang xuất bản gốc">
          <span>{nvinfo.pub_name}</span>
        </a>

        <a
          class="stat link"
          href="/books?origin={nvinfo.pub_name}"
          data-tip="Tìm truyện cùng nguồn"><SIcon name="search" /></a>
      {/if}
    </div>
  {/if}

  <div class="line">
    <div class="book-track">
      <BookTrack />
    </div>

    <a class="m-btn" href="/dicts/-{nvinfo.bhash}" data-kbd="p">
      <SIcon name="package" />
    </a>

    {#if $session.privi > 0}
      <a class="m-btn _harmful" href="/-{nvinfo.bslug}/+info">
        <SIcon name="edit" />
      </a>
    {/if}
  </div>
</div>

<section class="section island">
  <header class="section-header">
    <a
      href="/-{nvinfo.bslug}"
      class="header-tab"
      class:_active={nv_tab == 'index'}>
      <span>Tổng quan</span>
    </a>

    <a
      href="/-{nvinfo.bslug}/crits"
      class="header-tab"
      class:_active={nv_tab == 'crits'}>
      <span>Đánh giá</span>
    </a>

    <a
      href="/-{nvinfo.bslug}/chaps"
      class="header-tab"
      class:_active={nv_tab == 'chaps'}>
      <span>Chương tiết</span>
    </a>
  </header>

  <div class="section-content">
    <slot />
  </div>
</section>

<style lang="scss">
  .main-info {
    @include flow();
    @include margin-y(var(--gutter));
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
    &:hover {
      display: block;
    }
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

  .cover {
    float: left;
    @include bps(width, 40%, $pm: 35%, $pl: 30%, $ts: 25%);
  }

  .line {
    // float: right;
    padding-left: var(--gutter);
    gap: 0.5rem;

    @include bps(width, 60%, $pm: 65%, $pl: 70%, $ts: 75%);

    span :global(svg) {
      margin-top: -0.125rem;
    }

    margin-top: var(--gutter-pm);
    @include fgcolor(tert);
    @include flex($wrap: true);
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

  .section {
    margin: 0.5rem 0;

    @include bgcolor(tert);
    @include shadow(2);
    @include padding-x(var(--gutter));

    @include bp-min(tl) {
      border-radius: 1rem;
    }

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
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
