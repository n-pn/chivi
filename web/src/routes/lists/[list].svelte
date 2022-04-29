<script context="module" lang="ts">
  import { page } from '$app/stores'

  export async function load({ fetch, params, url }) {
    const id = params.list.split('-')[0]
    const api_url = `/api/yslists/${id}${url.search}`
    const api_res = await fetch(api_url)
    return await api_res.json()
  }

  const sorts = { utime: 'Gần nhất', stars: 'Điểm cao', score: 'Nổi bật' }
</script>

<script lang="ts">
  import { topbar } from '$lib/stores'
  import { rel_time } from '$utils/time_utils'
  import { SIcon } from '$gui'

  import Mpager, { Pager } from '$gui/molds/Mpager.svelte'
  import YscritCard from '$gui/sects/yscrit/YscritCard.svelte'

  export let ylist: CV.Yslist
  export let yl_id = ''

  export let crits: CV.Yscrit[] = []
  export let pgidx = 1
  export let pgmax = 1

  $: pager = new Pager($page.url, { _s: 'utime', pg: 1 })
  $: _sort = pager.get('_s')

  $: topbar.set({
    left: [
      ['Thư đơn', 'bookmarks', { href: '/lists' }],
      [ylist.vname, null, { href: '.', kind: 'title' }],
    ],
  })
</script>

<svelte:head>
  <title>Thư đơn: {ylist.vname} - Chivi</title>
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
      <span> Nguồn </span></a>
  </div>
</section>

<article class="article">
  <div class="sorts" id="sorts">
    <span class="h3 -label">Đánh giá</span>
    {#each Object.entries(sorts) as [sort, name]}
      <a
        href={pager.gen_url({ _s: sort, pg: 1 })}
        class="-sort"
        class:_active={sort == _sort}>{name}</a>
    {/each}
  </div>

  <div class="crits">
    {#each crits as crit}
      <YscritCard {crit} show_list={false} />
    {/each}

    <footer class="pagi">
      <Mpager {pager} {pgidx} {pgmax} />
    </footer>
  </div>
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

  .article {
    > * {
      @include padding-x(var(--gutter-large));
      // margin: 0 auto;
    }
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

  .sorts {
    line-height: 2rem;
    height: 2rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);

    .-label {
      flex: 1;
      // font-weight: 500;
      // @include ftsize(xl);
    }

    .-sort {
      @include fgcolor(tert);
      padding: 0 0.125rem;
      height: 2rem;

      &._active {
        border-bottom: 2px solid color(primary, 5);
        @include fgcolor(primary, 5);
      }
    }
  }
</style>
