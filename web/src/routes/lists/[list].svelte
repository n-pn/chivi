<script context="module" lang="ts">
  export async function load({ fetch, params, url }) {
    const id = params.list.split('-')[0]
    const api_url = `/api/yslists/${id}${url.search}`
    const api_res = await fetch(api_url)

    const payload = await api_res.json()

    const topbar = {
      left: [
        ['Thư đơn', 'bookmarks', { href: '/lists' }],
        [payload.props.ylist.vname, null, { href: '.', kind: 'title' }],
      ],

      right: [['Đánh giá', 'stars', { href: '/crits', show: 'tm' }]],
    }
    payload.stuff = { topbar }
    return payload
  }
</script>

<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'

  import YscritList from '$gui/sects/yscrit/YscritList.svelte'

  export let ylist: CV.Yslist
  export let yl_id = ''

  export let crits: CV.Yscrit[] = []
  export let pgidx = 1
  export let pgmax = 1
</script>

<svelte:head>
  <title>Thư đơn: {ylist.vname} - Chivi</title>
  <meta name="description" content={ylist.vdesc} />

  <meta property="og:title" content={ylist.vname} />
  <meta property="og:article" content="novel" />
  <meta property="og:description" content={ylist.vdesc} />
  <meta
    property="og:url"
    content="https://chivi.app/list/{ylist.id}{ylist.vslug}" />
  <meta
    property="og:image"
    content="https://chivi.app/covers/{ylist.covers[0] || 'blank.webp'}" />
</svelte:head>

<section class="content">
  <header class="header">
    <def class="left">
      <span class="entry">
        <SIcon name="user" />
        <a class="uname" href="/lists?by={ylist.op_id}-{ylist.uslug}"
          >{ylist.uname}</a>
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
      href="https://www.yousuu.com/booklist/{yl_id}"
      rel="noopener noreferer"
      target="_blank">
      <SIcon name="external-link" />
      <span>Nguồn</span></a>
  </div>
</section>

<article class="article">
  <YscritList {crits} {pgidx} {pgmax} _sort="utime" show_list={false} />
</article>

<style lang="scss">
  .content {
    @include padding-y(var(--gutter));
    // max-width: 42rem;
    // margin: 0 auto;
  }

  .origin {
    margin-bottom: 1rem;
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
