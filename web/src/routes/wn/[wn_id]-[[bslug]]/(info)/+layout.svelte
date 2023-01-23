<script lang="ts">
  import { page } from '$app/stores'

  import { SIcon, BCover } from '$gui'
  import { book_path } from '$lib/kit_path'

  import { map_status } from '$utils/nvinfo_utils'

  import RTime from '$gui/atoms/RTime.svelte'
  import UserAction from './UserAction.svelte'

  $: nvinfo = $page.data.nvinfo
  $: ubmemo = $page.data.ubmemo
  $: nv_tab = map_tab_from_route($page.route.id || '')

  function map_tab_from_route(route_id: string) {
    if (route_id.includes('crits')) return 'crits'
    if (route_id.includes('chaps')) return 'chaps'
    if (route_id.includes('lists')) return 'lists'
    return 'index'
  }

  $: root_path = book_path(nvinfo.id, nvinfo.btitle_vi).index
</script>

<div class="main-info">
  <div class="title" data-tip={nvinfo.btitle_hv} data-tip-loc="bottom">
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

  <div class="infos">
    <div class="line _clamp">
      <div class="stat -trim -author">
        <SIcon name="edit" />
        <a class="link -trim" href="/books/={nvinfo.author_vi}">
          <span class="label">{nvinfo.author_vi}</span>
        </a>
      </div>

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
  </div>

  <UserAction {nvinfo} {ubmemo} />
</div>

<section class="section island">
  <header class="section-header">
    <a href={root_path} class="header-tab" class:_active={nv_tab == 'index'}>
      <span>Tổng quan</span>
    </a>

    <a
      href="{root_path}/crits"
      class="header-tab"
      class:_active={nv_tab == 'crits'}>
      <span>Đánh giá</span>
    </a>

    <a
      href="{root_path}/lists"
      class="header-tab"
      class:_active={nv_tab == 'lists'}>
      <span>Thư đơn</span>
    </a>
  </header>

  <div class="section-content">
    <slot />
  </div>
</section>

<style lang="scss">
  .main-info {
    display: grid;
    gap: var(--gutter);
    justify-content: space-between;
    // prettier-ignore

    grid-template-columns: var(--cover-size, 40%) 1fr;
    // grid-template-rows: auto;

    grid-template-areas: 'a a' 'b c' 'd d';

    // @include flow();
    @include margin-y(var(--gutter));

    // prettier-ignore
    @include bp-min(pm) { --cover-size: 35%; }

    @include bp-min(pl) {
      --cover-size: 30%;
      grid-template-areas: 'b a' 'b c' 'b d';
      grid-template-rows: auto 2fr auto;
    }

    @include bp-min(ts) {
      --cover-size: 25%;
    }

    @include bp-min(tm) {
      --cover-size: max(20%, 13.5rem);
    }
  }

  .title {
    grid-area: a;

    // @include bps(width, 100%, $pl: 70%, $ts: 75%);
    // @include bps(padding-left, 0, $pl: var(--gutter));
  }

  .bname {
    @include fgcolor(secd);
    font-weight: 400;
    @include clamp($lines: 2);
    // prettier-ignore
    @include bps(font-size, rem(21px), rem(22px), rem(23px), rem(25px), rem(27px));
    @include bps(line-height, 1.5rem, $pl: 1.75rem, $ts: 2rem);
    // &:hover {
    //   display: block;
    // }
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
    grid-area: b;
    // float: left;
    // width: min(30vw, 12rem);
  }

  .infos {
    display: flex;
    flex-direction: column;
    grid-area: c;
    // gap: var(--gutter);
    justify-content: space-around;
  }

  .line {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;

    // prettier-ignore
    :global(svg) { margin-top: -0.125rem; }

    @include fgcolor(tert);

    &._clamp {
      @include bp-min(tm) {
        flex-direction: column;
      }
    }
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

    &.-author {
      max-width: 55vw;
    }
  }

  .label {
    font-weight: 500;
    // @include fgcolor(neutral, 8);
  }

  .section {
    @include margin-y(var(--gutter));

    @include bgcolor(tert);
    @include shadow(2);
    @include padding-x(var(--gutter));

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
