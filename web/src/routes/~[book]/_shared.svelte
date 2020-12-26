<script context="module">
  function map_status(status) {
    switch (status) {
      case 0:
        return 'Còn tiếp'
      case 1:
        return 'Hoàn thành'
      case 2:
        return 'Thái giám'
      default:
        return 'Không rõ'
    }
  }

  function gen_keywords(book) {
    let res = [book.zh_title, book.hv_title, book.vi_title]
    res.push(book.zh_author, book.vi_author)
    res.push(...book.vi_genres)
    res.push(...book.vi_tags)
    return res.join(',')
  }

  async function mark_book(bslug, new_mark) {
    if (mark == new_mark) mark = ''
    else mark = new_mark

    const url = `/api/self/book_mark/${bslug}?mark=${mark}`
    await fetch(url, { method: 'PUT' })
  }

  import { anchor_rel, self_power } from '$src/stores'
  import { mark_types, mark_names, mark_icons } from '$utils/constants'

  import SvgIcon from '$atoms/SvgIcon'
  import BookCover from '$atoms/BookCover'
  import RelTime from '$atoms/RelTime'

  import Vessel from '$parts/Vessel'
</script>

<script>
  export let book
  export let mark = ''
  export let atab = 'overview'

  $: vi_status = map_status(book.status)
  $: book_url = `https://chivi.xyz/~${book.slug}`
  $: book_intro = book.vi_intro.substring(0, 300)
  $: book_cover = `https://chivi.xyz/images/${book.ubid}.webp`
  $: updated_at = new Date(book.mftime)
  $: keywords = gen_keywords(book)
  $: has_links = book.yousuu_bid || book.origin_url
</script>

<svelte:head>
  <title>{book.vi_title} - Chivi</title>
  <meta name="keywords" content={keywords} />
  <meta name="description" content={book_intro} />

  <meta property="og:title" content={book.vi_title} />
  <meta property="og:type" content="novel" />
  <meta property="og:description" content={book_intro} />
  <meta property="og:url" content={book_url} />
  <meta property="og:image" content={book_cover} />

  <meta property="og:novel:category" content={book.vi_genres[0]} />
  <meta property="og:novel:author" content={book.vi_author} />
  <meta property="og:novel:book_name" content={book.vi_title} />
  <meta property="og:novel:read_url" content="{book_url}&tab=content" />
  <meta property="og:novel:status" content={vi_status} />
  <meta property="og:novel:update_time" content={updated_at.toISOString()} />
</svelte:head>

<Vessel>
  <a
    slot="header-left"
    href="/~{book.slug}"
    class="header-item _active"
    rel={$anchor_rel}>
    <SvgIcon name="book-open" />
    <span class="header-text _title">{book.vi_title}</span>
  </a>

  <span slot="header-right" class="header-item _menu">
    <SvgIcon name={mark ? mark_icons[mark] : 'bookmark'} />
    <span
      class="header-text _show-md">{mark ? mark_names[mark] : 'Đánh dấu'}</span>

    {#if $self_power > 0}
      <div class="header-menu">
        {#each mark_types as type}
          <div class="-item" on:click={() => mark_book(book.ubid, type)}>
            <SvgIcon name={mark_icons[type]} />
            <span>{mark_names[type]}</span>

            {#if mark == type}
              <span class="_right">
                <SvgIcon name="check" />
              </span>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </span>

  <div class="main-info">
    <h1 class="title">
      <span class="-main">{book.vi_title}</span>
      <span class="-sep">-</span>
      <span class="-sub">{book.zh_title}</span>
    </h1>

    <div class="cover">
      <BookCover ubid={book.ubid} path={book.main_cover} />
    </div>

    <section class="extra">
      <div class="line">
        <span class="stat">
          <SvgIcon name="pen-tool" />
          <a
            class="link"
            href="/search?kw={book.vi_author}&type=author"
            rel={$anchor_rel}>
            <span class="label">{book.vi_author}</span>
          </a>
        </span>

        {#each book.vi_genres as genre}
          <span class="stat _genre">
            <SvgIcon name="folder" />
            <a class="link" href="/?genre={genre}" rel={$anchor_rel}>
              <span class="label">{genre}</span>
            </a>
          </span>
        {/each}
      </div>

      <div class="line">
        <span class="stat _status">
          <SvgIcon name="activity" />
          <span>{vi_status}</span>
        </span>

        <span class="stat _mftime">
          <SvgIcon name="clock" />
          <span><RelTime time={book.mftime} /></span>
        </span>
      </div>

      <div class="line">
        <span class="stat">
          Đánh giá:
          <span class="label">{book.voters < 10 ? '--' : book.rating}</span>/10
        </span>
        <span class="stat">({book.voters} lượt đánh giá)</span>
      </div>

      {#if has_links}
        <div class="line">
          <span class="stat">Liên kết:</span>

          {#if book.origin_url != ''}
            <a
              class="stat link _outer"
              href={book.origin_url}
              rel="noopener noreferer"
              target="_blank">
              Trang gốc
            </a>
          {/if}

          {#if book.yousuu_bid !== ''}
            <a
              class="stat link _outer"
              href="https://www.yousuu.com/book/{book.yousuu_bid}"
              rel="noopener noreferer"
              target="_blank">
              Ưu thư võng
            </a>
          {/if}
        </div>
      {/if}
    </section>
  </div>

  <div class="page">
    <header class="page-header">
      <a
        href="/~{book.slug}"
        class="header-tab"
        class:_active={atab == 'overview'}
        rel="{$anchor_rel}}">
        Tổng quan
      </a>

      <a
        href="/~{book.slug}/content"
        class="header-tab"
        class:_active={atab == 'content'}
        rel="{$anchor_rel}}">
        Chương tiết
      </a>

      <a
        href="/~{book.slug}/discuss"
        class="header-tab"
        class:_active={atab == 'discuss'}
        rel="{$anchor_rel}}">
        Thảo luận
      </a>
    </header>

    <section class="page-content">
      <slot />
    </section>
  </div>
</Vessel>

<style lang="scss">
  .main-info {
    padding-top: 0.75rem;
    @include flow();
  }

  .title {
    font-weight: 400;
    @include fgcolor(neutral, 9);
    margin-bottom: 0.75rem;

    @include props(float, left, left, right);
    @include props(width, 100%, 100%, 70%, 75%);
    @include props(padding-left, 0, 0, 0.75rem);

    @include props(line-height, 1.5rem, 1.75rem, 2rem);
    @include props(font-size, rem(20px), rem(22px), rem(22px), rem(24px));
  }

  .cover {
    float: left;
    @include props(width, 40%, 35%, 30%, 25%);
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include props(width, 60%, 65%, 70%, 75%);

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .line {
    margin-bottom: 0.5rem;
    @include fgcolor(neutral, 6);
    @include flex($wrap: true);
    @include flex-gap($gap: 0, $child: ':global(*)');
  }

  .stat {
    margin-right: 0.5rem;
  }

  .link {
    // font-weight: 500;
    color: inherit;
    // @include fgcolor(primary, 7);
    &._outer,
    &:hover {
      @include fgcolor(primary, 6);
    }
  }

  .label {
    font-weight: 500;
    // @include fgcolor(neutral, 8);
  }

  .page {
    background-color: #fff;
    margin: 0.75rem -0.75rem;
    padding: 0 0.75rem;
    border-radius: 0.75rem;
    @include shadow(2);
    @include screen-min(lg) {
      margin-left: 0;
      margin-right: 0;
      padding-left: 1.5rem;
      padding-right: 1.5rem;
    }
  }

  $page-height: 3rem;
  .page-header {
    height: $page-height;
    display: flex;
    @include border($sides: bottom, $color: neutral, $shade: 3);
  }

  .header-tab {
    height: $page-height;
    line-height: $page-height;
    width: 50%;
    font-weight: 500;
    text-align: center;
    text-transform: uppercase;

    @include font-size(2);
    @include screen-min(md) {
      @include font-size(3);
    }

    @include fgcolor(neutral, 6);
    &._active {
      @include fgcolor(primary, 6);
      @include border($sides: bottom, $color: primary, $shade: 5, $width: 2px);
    }
  }

  .page-content {
    padding: 0.75rem 0;
    display: block;
    min-height: 50vh;
  }
</style>
