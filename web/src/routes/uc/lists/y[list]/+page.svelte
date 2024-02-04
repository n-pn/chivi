<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import YscritList from '$gui/parts/review/YscritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ ylist, yuser, crits, books, pgidx, pgmax } = data)

  $: users = { [yuser.id]: yuser }

  $: cover = ylist.covers[0] || 'blank.webp'
</script>

<svelte:head>
  <meta property="og:title" content={ylist.vname} />
  <meta property="og:article" content="novel" />
  <meta property="og:description" content={ylist.vdesc} />
  <meta property="og:url" content="//chivi.app/uc/lists/y{ylist.id}" />
  <meta property="og:image" content={cover} />
</svelte:head>

<section class="content">
  <header class="header">
    <def class="left">
      <span class="entry">
        <SIcon name="user" />
        <a class="uname" href="/uc/lists?from=ys&user={yuser.id}">{yuser.uname}</a>
      </span>

      <span class="entry">
        <SIcon name="clock" />
        <span>{rel_time(ylist.utime)}</span>
      </span>
    </def>

    <div class="right">
      <span class="entry" data-tip="Bộ truyện">
        <SIcon name="bookmarks" />
        <span>{ylist.book_count}</span>
      </span>

      <span class="entry" data-tip="Ưa thích">
        <SIcon name="heart" />
        <span>{ylist.like_count}</span>
      </span>

      <span class="entry" data-tip="Lượt xem">
        <SIcon name="eye" />
        <span>{ylist.view_count}</span>
      </span>
    </div>
  </header>

  <h1 class="vname">{ylist.vname}</h1>

  <div class="genres">
    {#each ylist.genres as genre}
      <span class="genre">{genre}</span>
    {/each}
  </div>

  <div class="vdesc">
    {@html ylist.vdesc
      .split('\n')
      .map((x) => `<p>${x}</p>`)
      .join('\n')}
  </div>

  <div class="origin">
    <a
      class="m-link m-iflex _cy"
      href="https://www.yousuu.com/booklist/{ylist.orig_id}"
      rel="noreferrer"
      target="_blank">
      <SIcon name="external-link" />
      <span>Nguồn Ưu Thư Võng</span></a>
  </div>
</section>

<YscritList
  {crits}
  {users}
  {books}
  {pgidx}
  {pgmax}
  qdata={{ sort: 'utime', smin: 0, smax: 6, pg: 1 }}
  show_list={false} />

<style lang="scss">
  .content {
    @include padding-y(var(--gutter));
    // max-width: 42rem;
    // margin: 0 auto;
  }

  .vname {
    @include fgcolor(secd);
    @include ftsize(x3);
    // line-height: 1.75rem;
    font-weight: 500;
    margin: 0.5rem 0;
  }

  .genres {
    // display: flex;
    margin: 0.5rem 0;
  }

  .genre {
    @include fgcolor(tert);
    font-weight: 500;
    margin-right: 0.5rem;
    font-size: rem(15px);
  }

  .header {
    display: flex;
  }

  .left {
    flex: 1;
  }

  .uname {
    font-weight: 500;
    @include fgcolor(secd);
  }

  .entry {
    display: inline-flex;
    gap: 0.125rem;
    align-items: center;
    @include fgcolor(tert);

    :global(svg) {
      @include fgcolor(mute);
    }

    & + & {
      margin-left: 0.25rem;
    }
  }

  .vdesc :global(p) {
    margin-bottom: 0.75rem;
  }
</style>
