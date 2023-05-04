<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData
  $: ({ list } = data)

  $: list_path = `/@${list.u_uname}/ul/${list.tslug}`
</script>

<svelte:head>
  <meta property="og:url" content="https://chivi.app/{list_path}" />
</svelte:head>

<section class="content">
  <header class="header">
    <def class="left">
      <a class="cv-user" href="/@{list.u_uname}" data-privi={list.u_privi}
        >{list.u_uname}</a>

      <span class="fg-tert">&middot;</span>

      <span class="entry">
        <span>{rel_time(list.utime)}</span>
      </span>

      {#if $_user.uname == list.u_uname}
        <span class="fg-tert">&middot;</span>
        <a class="entry fs-i" href="/ul/+list?id={list.vl_id}">Sửa</a>
      {/if}
    </def>

    <div class="right">
      <span class="entry" data-tip="Bộ truyện">
        <SIcon name="bookmarks" />
        <span>{list.book_count}</span>
      </span>

      <span class="entry" data-tip="Ưa thích">
        <SIcon name="heart" />
        <span>{list.like_count}</span>
      </span>

      <span class="entry" data-tip="Lượt xem">
        <SIcon name="eye" />
        <span>{list.view_count}</span>
      </span>
    </div>
  </header>

  <h1 class="vname">{list.title}</h1>

  <div class="genres">
    {#each list.genres as genre}
      <span class="genre">{genre}</span>
    {/each}
  </div>

  <div class="vdesc">
    {@html list.dhtml}
  </div>
</section>

<article class="article island">
  <WncritList vi={data.books} ys={undefined} _sort="utime" show_list={false} />
</article>

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
