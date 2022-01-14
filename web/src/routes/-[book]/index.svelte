<script context="module">
  import { page } from '$app/stores'

  export async function load({ fetch, stuff: { nvinfo } }) {
    const crit_url = `/api/crits?book=${nvinfo.id}&page=1&take=3&sort=stars`
    const crit_res = await fetch(crit_url)
    const { crits } = await crit_res.json()

    const book_url = `/api/authors/${nvinfo.author_id}/books?take=7`
    const book_res = await fetch(book_url)

    const { books: book_raw } = await book_res.json()
    const books = book_raw.filter((x) => x.id != nvinfo.id)

    return { props: { crits, books } }
  }
</script>

<script>
  import Nvlist from '$parts/Nvlist.svelte'
  import Yscrit from '$parts/Yscrit.svelte'
  import BookPage from './_layout/BookPage.svelte'

  export let crits = []
  export let books = []

  $: nvinfo = $page.stuff.nvinfo

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
      <a
        class="sub-link"
        href="/search?t=author&q={encodeURIComponent(nvinfo.author)}"
        >Xem tất cả</a>
    </h3>

    {#if books.length > 0}
      <Nvlist {books} />
    {:else}
      <div class="empty">Danh sách trống</div>
    {/if}
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
</style>
