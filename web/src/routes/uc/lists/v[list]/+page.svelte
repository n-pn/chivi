<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time } from '$utils/time_utils'
  import { toggle_like } from '$utils/memo_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ list, qdata, pager } = data)

  const handle_like = (evt: Event) => {
    evt.preventDefault()

    toggle_like('vilist', list.vl_id, list.me_liked, ({ like_count, memo_liked }) => {
      list.like_count = like_count
      list.me_liked = memo_liked
    })
  }
</script>

<section class="content">
  <header class="header">
    <def class="left">
      <a class="uname v" href="/uc/lists?from=vi&user={list.u_uname}" data-privi={list.u_privi}
        >{list.u_uname}</a>

      <span class="u-fg-tert">&middot;</span>

      <span class="m-meta">
        <span>{rel_time(list.utime)}</span>
      </span>

      {#if $_user.uname == list.u_uname}
        <span class="u-fg-tert">&middot;</span>
        <a class="m-meta fs-i" href="/uc/lists/+list?id={list.vl_id}">Sửa</a>
      {/if}
    </def>

    <div class="right">
      <span class="m-meta" data-tip="Bộ truyện">
        <SIcon name="bookmarks" />
        <span>{list.book_count}</span>
      </span>

      <button
        type="button"
        class="m-meta"
        data-tip="Ưa thích"
        class:_active={list.me_liked > 0}
        disabled={$_user.privi < 0}
        on:click={handle_like}>
        <SIcon name="heart" />
        <span>{list.like_count}</span>
      </button>

      <span class="m-meta" data-tip="Lượt xem">
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

<WncritList vdata={data.books} ydata={undefined} {qdata} {pager} show_list={false} _mode={1} />

<style lang="scss">
  .content {
    margin-top: 0.75rem;
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
</style>
