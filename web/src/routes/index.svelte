<script context="module">
  export async function preload({ query }) {
    const page = query.page || 1
    let url = `api/books?page=${page}`
    const sort = query.sort || 'access'
    url += `&sort=${sort}`

    const res = await this.fetch(url)
    const data = await res.json()
    return Object.assign(data, { page })
  }

  export function page_url(page = 1, sort = 'access') {
    const params = {}
    if (page > 1) params.page = page
    if (sort !== 'access') params.sort = sort

    const query = Object.entries(params)
      .map(([k, v]) => `${k}=${v}`)
      .join('&')

    if (query) return `/?${query}`
    return '/'
  }
</script>

<script>
  import MIcon from '$mould/MIcon.svelte'
  import Header from '$layout/Header.svelte'

  export let items = []
  export let total = 0
  export let page = 1
  export let sort = 'access'

  const sorts = {
    access: 'Vừa xem',
    update: 'Mới cập nhật',
    score: 'Đánh giá',
    votes: 'Lượt đánh giá',
    tally: 'Tổng hợp',
  }

  $: page_max = Math.floor((total - 1) / 20) + 1
  $: pages = make_pages(page, page_max)

  import { onMount } from 'svelte'
  import { lookup_active } from '$src/stores.js'
  onMount(() => lookup_active.set(false))

  function make_pages(page_now, page_max) {
    let page_from = page_now - 2
    if (page_from < 1) page_from = 1
    let page_upto = page_from + 4
    if (page_upto > page_max) {
      page_upto = page_max
      page_from = page_upto - 4
      if (page_from < 1) page_from = 1
    }

    // console.log({ page_from, page_upto })
    let arr = []
    for (let i = page_from; i <= page_upto; i++) arr.push(i)
    return arr
  }
</script>

<style lang="scss">
  .list {
    max-width: 100%;
    margin: 0.75rem;

    @include grid($gap: 0.5rem, $size: minmax(8.5rem, 1fr));
  }

  .book {
    display: block;
    position: relative;

    margin-bottom: 3rem;

    @include hover {
      .book-title {
        @include fgcolor(color(primary, 5));
      }
    }
    // overflow: hidden;
    &::before {
      content: '';
      display: block;
      padding-top: 4/3;
      position: absolute;
      top: 0;
      left: 0;
      z-index: -1;
    }
  }

  .book-cover {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    z-index: 1;

    // source,
    img {
      @include radius();
      // display: block;
      min-width: 100%;
      min-height: 100%;
    }
  }

  .book-title {
    width: 100%;
    position: absolute;
    bottom: -1.75rem;
    font-weight: 600;
    @include fgcolor(color(neutral, 7));
    @include truncate();
    @include font-size(3);
    @include font-family(narrow);
  }

  .book-genre {
    width: 100%;
    position: absolute;
    bottom: -3rem;
    @include fgcolor(color(neutral, 5));
    text-transform: uppercase;
    font-weight: 500;
    @include font-size(1);
  }

  .book-score {
    width: 100%;
    position: absolute;
    bottom: -3rem;
    text-transform: uppercase;
    font-weight: 500;
    text-align: right;

    @include fgcolor(color(neutral, 5));
    @include font-size(1);

    > span {
      display: inline-block;
      vertical-align: top;
      font-size: 95%;
      // margin-top: -0.125rem;
    }
  }

  .pagi {
    margin: 0.75rem;
    display: flex;
    justify-content: center;
  }

  .page {
    & + & {
      margin-left: 0.5rem;
    }
  }

  .sort {
    margin: 0.75rem;
    margin-top: 0.25rem;

    line-height: 2rem;
    @include clearfix;
    .label {
      float: left;
      font-weight: 500;
      padding-top: 0.375rem;

      @include font-size(5);
      // @include fgcolor(color(neutral, 6));
    }
    .type {
      float: left;
      margin-left: 0.5rem;
      margin-top: 0.5rem;

      text-transform: uppercase;
      padding: 0 0.5rem;
      font-weight: 500;
      cursor: pointer;
      @include fgcolor(color(neutral, 7));
      @include font-size(2);

      @include border();
      @include radius();
      &._active {
        @include fgcolor(color(primary, 5));
        @include border-color($value: color(primary, 5));
      }
    }
  }
</style>

<svelte:head>
  <title>Chivi - Chinese to Vietname Machine Translation</title>
</svelte:head>

<Header />

<div class="wrapper">
  <div class="sort">
    <span class="label">Sắp xếp theo:</span>
    {#each Object.entries(sorts) as [type, label]}
      <a class="type" class:_active={sort == type} href="/?sort={type}">
        {label}
      </a>
    {/each}
  </div>
  <div class="list">
    {#each items as book}
      <a class="book" href={book.vi_slug}>
        <picture class="book-cover">
          {#each book.covers as cover}
            <source srcset={cover} />
          {/each}
          <img src="/img/nocover.png" alt={book.vi_title} />
        </picture>

        <div class="book-title">{book.vi_title}</div>
        <div class="book-genre">{book.vi_genre}</div>
        <div class="book-score">
          <span>⭐</span>
          {book.score}
        </div>
      </a>
    {/each}
  </div>

  <footer class="pagi">
    {#if page == 1}
      <button class="page m-button _line" disabled>
        <MIcon class="m-icon" name="chevrons-left" />
      </button>
    {:else}
      <a class="page m-button _line" href={page_url(1, sort)}>
        <MIcon class="m-icon" name="chevrons-left" />
      </a>
    {/if}

    {#each pages as idx}
      {#if page == idx}
        <button class="page m-button _line _primary" disabled>
          <span>{idx}</span>
        </button>
      {:else}
        <a class="page m-button _line" href={page_url(idx, sort)}>
          <span>{idx}</span>
        </a>
      {/if}
    {/each}
    {#if page == page_max}
      <button class="page m-button _line" disabled>
        <MIcon class="m-icon" name="chevrons-right" />
      </button>
    {:else}
      <a class="page m-button _line" href={page_url(page_max, sort)}>
        <MIcon class="m-icon" name="chevrons-right" />
      </a>
    {/if}

  </footer>

</div>
