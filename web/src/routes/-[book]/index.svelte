<script context="module">
  import { page } from '$app/stores'
  import { status_icons, status_names, status_colors } from '$lib/constants.js'

  export async function load({ fetch, stuff: { nvinfo } }) {
    const api_url = `/api/books/${nvinfo.bhash}/front`
    const api_res = await fetch(api_url)
    return { props: await api_res.json() }
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import Nvlist from '$parts/Nvlist.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import BookPage from './_layout/BookPage.svelte'

  export let crits = []
  export let books = []
  export let users = []

  $: nvinfo = $page.stuff.nvinfo || {}

  let short_intro = false
</script>

<BookPage nvtab="index">
  <article class="m-article">
    <h2>Giới thiệu:</h2>
    <div class="intro" class:_short={short_intro}>
      {#each nvinfo.bintro as para}
        <p>{para}</p>
      {/each}
    </div>

    <h3 class="sub">
      <sub-label>Đánh giá nổi bật</sub-label>
      <a class="sub-link" href="/-{nvinfo.bslug}/crits">Xem tất cả</a>
    </h3>

    <div class="crits">
      {#each crits as crit}
        <Yscrit {crit} show_book={false} view_all={crit.vhtml.length < 640} />
      {:else}
        <div class="empty">Chưa có đánh giá</div>
      {/each}
    </div>

    <h3 class="sub">
      <sub-label>Truyện đồng tác giả</sub-label>
      <a class="sub-link" href="/books/={nvinfo.author}">Xem tất cả</a>
    </h3>

    {#if books.length > 0}
      <Nvlist {books} />
    {:else}
      <div class="empty">Danh sách trống</div>
    {/if}

    <h3 class="sub">
      <sub-label>Danh sách độc giả</sub-label>
    </h3>

    <div class="users">
      {#each users as { u_dname, u_privi, _status }}
        <a
          class="m-chip _{status_colors[_status]}"
          href="/books/@{u_dname}?bmark={_status}"
          data-tip="[{status_names[_status]}]">
          <cv-user privi={u_privi}>{u_dname}</cv-user>
          <SIcon name={status_icons[_status]} />
        </a>
      {:else}
        <div class="empty">Chưa có người đọc</div>
      {/each}
    </div>
  </article>
</BookPage>

<style lang="scss">
  article {
    @include bps(margin-left, 0rem, 0.1rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.1rem, 1.5rem, 2rem);
  }

  .intro {
    word-wrap: break-word;
    @include fgcolor(secd);
    // @include bps(padding, $md: 0 0.75rem);
    @include bps(font-size, rem(15px), rem(16px), rem(17px));

    &._short {
      height: 20rem;
      overflow-y: scroll;
      scrollbar-width: thin;
      scrollbar-color: color(gray, 8);
    }

    p {
      margin-top: 0.75rem;
    }
  }

  .sub {
    line-height: 2rem;
    height: 2rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);
  }

  sub-label {
    flex: 1;
  }

  .sub-link {
    font-style: italic;
    @include ftsize(md);
    @include fgcolor(tert);
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .empty {
    font-style: italic;
    text-align: center;
    @include fgcolor(mute);
    @include ftsize(sm);
  }

  .m-chip {
    margin-right: 0.5rem;
    display: inline-flex;
    align-items: center;

    > cv-user {
      padding: 0 0.25rem;
    }
  }
</style>
