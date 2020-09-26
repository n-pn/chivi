<script context="module">
  export function map_status(status) {
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

  export function gen_keywords(book) {
    let res = [book.zh_title, book.hv_title, book.vi_title]
    res.push(book.zh_author, book.vi_author)
    res.push(...book.vi_genres)
    res.push(...book.vi_tags)
    return res.join(',')
  }
</script>

<script>
  import SvgIcon from '$atoms/SvgIcon'
  import BookCover from '$atoms/BookCover'
  import RelTime from '$atoms/RelTime'

  export let book

  $: vi_status = map_status(book.status)
  $: book_url = `https://chivi.xyz/~${book.slug}/`
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
        <a class="link" href="/search?kw={book.vi_author}&type=author">
          <span class="label">{book.vi_author}</span>
        </a>
      </span>

      {#each book.vi_genres as genre}
        <span class="stat _genre">
          <SvgIcon name="folder" />
          <a class="link" href="/?genre={genre}">
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
        Đánh giá: <span
          class="label">{book.voters < 10 ? '--' : book.rating}</span>/10
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

<style lang="scss">
  .main-info {
    padding-top: 0.75rem;
    @include clearfix;
  }

  .title {
    $line-heights: screen-vals(1.5rem, 1.75rem, 2rem);
    $font-sizes: screen-vals(rem(26px), rem(28px), rem(30px));

    font-weight: 300;
    margin-bottom: 0.75rem;
    // @include clearfix;

    @include apply(float, screen-vals(left, right));
    @include apply(width, screen-vals(100%, 70%, 75%));
    @include apply(padding-left, screen-vals(0, 0.75rem));

    @include apply(line-height, $line-heights);
    @include apply(font-size, $font-sizes);

    .-sub {
      font-size: 0.875em;
      line-height: 1em;
    }
  }

  .cover {
    float: left;
    @include apply(width, screen-vals(40%, 30%, 25%));
  }

  .extra {
    float: right;
    padding-left: 0.75rem;

    @include apply(width, screen-vals(60%, 70%, 75%));

    :global(svg) {
      margin-top: -0.125rem;
    }
  }

  .line {
    margin-bottom: 0.5rem;
    @include flex($gap: 0);
    flex-wrap: wrap;
    @include fgcolor(neutral, 6);
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
  }
</style>
