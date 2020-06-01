<script context="module">
  export async function preload({ query }) {
    const page = +(query.page || 1)
    let url = `api/books?page=${page}`
    const sort = query.sort || 'access'
    url += `&sort=${sort}`

    const res = await this.fetch(url)
    const data = await res.json()
    return Object.assign(data, { page })
  }

  export function makePageUrl(page = 1, sort = 'access') {
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
  import Layout from '$layout/Layout.svelte'
  import paginate_range from '$utils/paginate_range'

  export let items = []
  export let total = 0
  export let page = 1
  export let sort = 'access'

  const sorts = {
    access: 'Vừa xem',
    update: 'Đổi mới',
    score: 'Đánh giá',
    tally: 'Tổng hợp',
  }

  $: pageMax = Math.floor((total - 1) / 20) + 1
  $: pageList = paginate_range(page, pageMax)

  import { searching } from '$src/stores'

  function handleKeypress(evt) {
    if ($searching == true) return

    switch (evt.keyCode) {
      case 72:
        evt.preventDefault()
        changePage(1)
        break

      case 76:
        evt.preventDefault()
        changePage(pageMax)
        break

      case 37:
      case 74:
        if (!evt.altKey) {
          evt.preventDefault()
          changePage(page - 1)
        }
        break

      case 39:
      case 75:
        if (!evt.altKey) {
          evt.preventDefault()
          changePage(page + 1)
        }
        break

      default:
        break
    }
  }

  function changePage(newPage) {
    if (newPage >= 1 && newPage <= pageMax) _goto(makePageUrl(newPage, sort))
  }
</script>

<svelte:head>
  <title>Chivi - Chinese to Vietname Machine Translation</title>
</svelte:head>

<svelte:window on:keydown={handleKeypress} />

<Layout>
  <div class="sort">
    {#each Object.entries(sorts) as [type, label]}
      <a class="sort-type" class:_active={sort == type} href="/?sort={type}">
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <div class="list">
    {#each items as book}
      <a class="book" href={book.slug} rel="prefetch">
        <picture class="book-cover">
          <source srcset="/images/{book.uuid}.webp" type="image/webp" />
          <source srcset="/covers/{book.uuid}.jpg" type="image/jpeg" />
          <img src="/covers/{book.uuid}.jpg" alt="" loading="lazy" />
        </picture>

        <div class="book-title">{book.vi_title}</div>
        <div class="-genre">{book.vi_genre}</div>
        <div class="-score">
          <span class="--icon">⭐</span>
          <span class="--text">{book.votes < 10 ? '--' : book.score}</span>
        </div>
      </a>
    {/each}
  </div>

  <div class="pagi">
    <a
      class="page m-button _line"
      class._disable={page == 1}
      href={makePageUrl(1, sort)}>
      <MIcon class="m-icon" name="chevrons-left" />
    </a>

    <a
      class="page m-button _line"
      class._disable={page == 1}
      href={makePageUrl(+page - 1, sort)}>
      <MIcon class="m-icon" name="chevron-left" />
    </a>

    {#each pageList as [index, level]}
      <a
        class="page m-button _line"
        class._disable={page == index}
        data-level={level}
        href={makePageUrl(index, sort)}>
        <span>{index}</span>
      </a>
    {/each}

    <a
      class="page m-button _line"
      disabled={page == pageMax}
      href={makePageUrl(page + 1, sort)}>
      <MIcon class="m-icon" name="chevron-right" />
    </a>

    <a
      class="page m-button _line"
      disabled={page == pageMax}
      href={makePageUrl(pageMax, sort)}>
      <MIcon class="m-icon" name="chevrons-right" />
    </a>

  </div>

</Layout>

<style lang="scss">
  .list {
    max-width: 100%;
    margin: 0;

    @include grid($gap: 0.5rem, $size: minmax(8.5rem, 1fr));
  }

  .book {
    display: block;
    position: relative;

    margin-bottom: 3rem;

    @include hover {
      .book-title {
        @include fgcolor(primary, 5);
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

    .-genre,
    .-score {
      // width: 100%;
      position: absolute;
      // bottom: 0.375rem;
      bottom: -2.75rem;
      // padding: 0.125rem 0.25rem;
      text-transform: uppercase;
      font-weight: 500;
      @include fgcolor(neutral, 5);
      // @include bgcolor(rgba(color(neutral, 9), 0.3));
      @include font-size(1);
      @include radius();
    }
    .-genre {
      // left: 0.375rem;
      left: 0;
    }

    .-score {
      // right: 0.375rem;
      right: 0;
      text-transform: uppercase;
      text-align: right;

      > span {
        display: inline-block;
        vertical-align: top;
        font-size: 95%;
        // margin-top: -0.125rem;
      }
    }
  }

  .book-title {
    width: 100%;
    position: absolute;
    bottom: -1.75rem;
    font-weight: 500;
    @include fgcolor(neutral, 7);
    @include truncate();
    @include font-size(3);
    // line-height: 1rem;
    // @include font-family(narrow);
  }

  .book-cover {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    z-index: 1;

    img {
      width: 100%;
      max-height: 100%;
      object-fit: cover;
      @include radius();
    }
  }

  .sort {
    @include flex($gap: 0.375rem);
    overflow: auto;
    justify-content: center;

    margin: 0.75rem 0;
    line-height: 2rem;
  }

  .sort-type {
    text-transform: uppercase;
    padding: 0 0.5rem;
    font-weight: 500;
    @include truncate(null);

    @include fgcolor(neutral, 7);
    @include font-size(2);
    @include border();
    @include radius();
    &._active {
      @include fgcolor(primary, 5);
      @include bdcolor($color: primary, $shade: 5);
    }
  }

  $footer-height: 4rem;

  // :global(.footer) {
  //   position: sticky;
  //   bottom: 0;
  //   left: 0;
  //   width: 100%;
  //   transition: transform 0.1s ease-in-out;
  //   @include bgcolor(rgba(color(neutral, 1), 0.8));

  //   :global(.main._clear) & {
  //     transform: translateY($footer-height);
  //     background-color: transparent;
  //     margin-bottom: 0;
  //   }
  // }

  .pagi {
    margin: 0.75rem 0;
    @include flex($gap: 0.375rem);
    justify-content: center;
  }

  .page {
    &[disabled] {
      cursor: text;
    }

    & + & {
      margin-left: 0.5rem;
    }

    & + & {
      margin-left: 0.375rem;
    }

    &[data-level] {
      display: none;
    }

    &[data-level='0'] {
      display: inline-block;
    }

    &[data-level='1'] {
      @include screen-min(sm) {
        display: inline-block;
      }
    }

    &[data-level='2'] {
      @include screen-min(md) {
        display: inline-block;
      }
    }

    &[data-level='3'],
    &[data-level='4'] {
      @include screen-min(lg) {
        display: inline-block;
      }
    }
  }
</style>
