<script lang="ts">
  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import BCover from '$gui/atoms/BCover.svelte'

  import { map_status } from '$utils/nvinfo_utils'

  import RTime from '$gui/atoms/RTime.svelte'
  import Section from '$gui/sects/Section.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'

  $: nvinfo = $page.data.nvinfo

  $: rpath = `/wn/${nvinfo.bslug}`

  $: tabs = [
    { type: 'fp', href: rpath, icon: 'news', text: 'Tổng quan' },
    { type: 'uc', href: `${rpath}/uc`, icon: 'stars', text: 'Đánh giá' },
    { type: 'ul', href: `${rpath}/ul`, icon: 'bookmarks', text: 'Thư đơn' },
    // { type: 'gd', href: `${rpath}/gd`, icon: 'message', text: 'Thảo luận' },
  ]
</script>

<div class="wninfo">
  <div class="title" data-tip={nvinfo.htitle} data-tip-loc="bottom">
    <h1 class="bname _main">
      <bname-vi>{nvinfo.vtitle}</bname-vi>
      {#if nvinfo.ztitle != nvinfo.vtitle}
        <bname-sep>/</bname-sep>
        <bname-zh>{nvinfo.ztitle}</bname-zh>
      {/if}
      {#if nvinfo.htitle != nvinfo.vtitle && nvinfo.htitle != nvinfo.ztitle}
        <bname-sep>/</bname-sep>
        <bname-vi>{nvinfo.htitle}</bname-vi>
      {/if}
    </h1>
  </div>

  <div class="cover">
    <BCover srcset={nvinfo.bcover} />
  </div>

  <div class="infos">
    <div class="line _clamp">
      <div class="stat -trim -author">
        <SIcon name="edit" />
        <a class="link -trim" href="/wn/={nvinfo.vauthor}">
          <span class="label">{nvinfo.vauthor}</span>
        </a>
      </div>

      <div class="bgenres">
        {#each nvinfo.genres || [] as genre, idx}
          <span class="stat _genre" class:_trim={idx > 1}>
            <a class="link" href="/wn/~{genre}">
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

    <div class="line">
      <span class="stat">Liên kết:</span>

      {#each nvinfo.origins as { name, link, type }}
        <a
          class="stat link _outer"
          href={link}
          rel="noreferrer"
          target="_blank">
          <span>{name}</span>
        </a>

        {#if type == 1}
          <a
            class="stat link"
            href="/wn?origin={name}"
            data-tip="Tìm truyện cùng nguồn"><SIcon name="search" /></a>
        {/if}
      {/each}
    </div>
  </div>

  <UserMemo crepo={$page.data.crepo} rmemo={$page.data.rmemo} />
</div>

<Section {tabs}>
  <slot />
</Section>

<style lang="scss">
  .wninfo {
    display: grid;
    gap: var(--gutter);
    justify-content: space-between;
    // prettier-ignore

    grid-template-columns: var(--cover-size, 40%) 1fr;
    // grid-template-rows: auto;

    grid-template-areas: 'a a' 'b c' 'd d';

    margin-bottom: var(--gutter);

    // prettier-ignore
    @include bp-min(pm) {
      --cover-size: 35%;
    }

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
</style>
