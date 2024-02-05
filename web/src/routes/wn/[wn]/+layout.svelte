<script lang="ts">
  import { map_status } from '$utils/nvinfo_utils'

  import { page } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import BCover from '$gui/atoms/BCover.svelte'

  import RTime from '$gui/atoms/RTime.svelte'
  import Section from '$gui/sects/Section.svelte'
  import UserMemo from '$gui/shared/wnovel/UserMemo.svelte'

  function gen_keywords(nvinfo: CV.Wninfo) {
    const kw = [
      nvinfo.ztitle,
      nvinfo.vtitle,
      nvinfo.htitle,
      nvinfo.zauthor,
      nvinfo.vauthor,
      ...nvinfo.genres,
    ]
    return kw.filter((v, i, a) => i != a.indexOf(v)).join(',')
  }

  $: tabs = [
    { type: '', href: rpath, icon: 'news', text: 'Tổng quan' },
    { type: 'crits', href: `${rpath}/crits`, icon: 'stars', text: 'Đánh giá' },
    {
      type: 'lists',
      href: `${rpath}/lists`,
      icon: 'bookmarks',
      text: 'Thư đơn',
    },
    {
      type: 'bants',
      href: `${rpath}/bants`,
      icon: 'message',
      text: 'Thảo luận',
    },
  ]

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: binfo = data.nvinfo
  $: rpath = `/wn/${binfo.id}`
  $: genres = binfo.genres || []
  $: update = new Date(binfo.mftime || 0).toISOString()
</script>

<svelte:head>
  <meta name="keywords" content={gen_keywords(binfo)} />

  <meta property="og:type" content="novel" />
  <meta property="og:novel:category" content={genres[0]} />
  <meta property="og:novel:author" content={binfo.vauthor} />
  <meta property="og:novel:book_name" content={binfo.vtitle} />
  <meta property="og:novel:status" content={map_status(binfo.status)} />
  <meta property="og:novel:update_time" content={update} />
</svelte:head>

<section class="bwrap">
  <div class="binfo">
    <h1 class="title">
      <h1 class="bname">{binfo.vtitle}</h1>
    </h1>

    <div class="links">
      <a class="m-chip _warning" href="/wn/={binfo.vauthor}">
        <SIcon name="edit" />
        <span class="-trim">{binfo.vauthor}</span>
      </a>

      {#each binfo.genres || [] as genre, idx}
        <a href="/wn/~{genre}" class="m-chip _primary" class:_trim={idx > 1}>
          <SIcon name="folder" />
          <span class="-text">{genre}</span>
        </a>
      {/each}
    </div>

    <div class="stats">
      <span class="stat _status">
        <SIcon name="activity" />
        <span>{map_status(binfo.status)}</span>
      </span>

      <span class="stat _mftime">
        <SIcon name="clock" />
        <span><RTime mtime={binfo.mftime} /></span>
      </span>
    </div>

    <div class="stats">
      <span class="stat">
        <span>Đánh giá: </span><span class="label">{binfo.voters <= 10 ? '--' : binfo.rating}</span
        >/10</span>
      <span class="stat">({binfo.voters} lượt<span class="trim">&nbsp;đánh giá</span>)</span>
    </div>
  </div>

  <div class="cover">
    <BCover srcset={binfo.bcover} />
  </div>
</section>

<UserMemo
  crepo={$page.data.crepo}
  rmemo={$page.data.rmemo}
  conf_path={`/wn/+book?id=${binfo.id}`} />

<Section {tabs}>
  <slot />
</Section>

<style lang="scss">
  .bwrap {
    display: flex;
  }

  .binfo {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .title {
    display: block;

    @include ftsize(x2);
    @include fgcolor(secd);
  }

  .links {
    @include fgcolor(tert);
    @include flex-cy($gap: 0.5rem);
    flex-wrap: wrap;
    font-style: normal;

    @include bps(font-size, rem(14px), $pl: rem(15px), $ts: rem(16px), $tm: rem(17px));
  }

  .stats {
    @include flex($gap: 0.5rem);
    font-style: italic;
    line-height: 1em;
    padding: 0.25em;

    @include bps(font-size, rem(13px), $pl: rem(14px), $ts: rem(15px), $tm: rem(16px));
  }

  .cover {
    width: 30vw;
    max-width: 96px;
    padding-left: 0.75rem;
    margin-left: auto;
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

  // .line {

  //   .stats {
  //     @include flex($gap: 0.5rem);
  //     font-style: italic;
  //     margin-bottom: 0.5rem;
  //     line-height: 1em;
  //     padding: 0.25em;

  //     @include bps(font-size, rem(13px), $pl: rem(14px), $ts: rem(15px), $tm: rem(16px));
  //   }

  // }

  .-trim {
    // max-width: 100%;
    max-width: 50vw;
    @include clamp($width: null);
  }
</style>
