<script lang="ts">
  import { map_status } from '$utils/nvinfo_utils'
  import { rel_time } from '$utils/time_utils'

  import { SIcon, BCover } from '$gui'

  export let book: CV.Crbook
</script>

<section class="book">
  <a class="-cover" href="/wn/{book.bslug}">
    <BCover bcover={book.bcover} scover={book.scover} class="square" />
  </a>

  <div class="-info">
    <div class="-title">
      <a class="link _title" href="/wn/{book.bslug}">
        <span>{book.btitle}</span>
      </a>
    </div>
    <div class="-extra">
      <a class="link _author" href="/books/={book.author}">
        <SIcon name="edit" />
        <span>{book.author}</span>
      </a>

      <a class="link _genre" href="/books/-{book.bgenre}">
        <SIcon name="folder" />
        <span>{book.bgenre}</span>
      </a>
    </div>
    <div class="-extra">
      <span class="meta">
        <SIcon name="activity" />
        <span>{map_status(book.status)}</span>
      </span>

      <span class="meta">
        <SIcon name="clock" />
        <span>{rel_time(book.update)}</span>
      </span>
    </div>
  </div>

  <div class="-vote">
    {#if book.voters > 0}
      <div class="-rating" data-tip="Đánh giá">{book.rating}</div>
      <div class="-voters" data-tip="Lượt đánh giá" data-tip-loc="bottom">
        {book.voters} lượt
      </div>
    {/if}
  </div>
</section>

<style lang="scss">
  .book {
    @include flex($gap: 0.5rem);
    // @include bgcolor(secd);

    // @include border(--bd-soft);
    // @include shadow();
    // @include bdradi($loc: top);

    @include border(--bd-soft, $loc: bottom);
    // margin-top: 0.75rem;

    @include padding-y(calc(var(--gutter) / 2));
    @include padding-x(var(--gutter));
  }

  .-info {
    overflow: hidden;
  }

  .-vote {
    min-width: 3.5rem;
    margin-left: auto;
    margin-right: 0.5rem;
    flex-direction: column;
    @include flex-ca;
  }

  .-title,
  .-extra {
    @include flex($gap: 0.5rem);
    line-height: 1.5rem;
  }

  .-title {
    @include ftsize(md);
    @include fgcolor(secd);
    @include clamp($width: null);
    margin-top: 0.5rem;
  }

  .-extra {
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .-rating {
    font-weight: 500;
    margin-bottom: 0.25rem;
    @include ftsize(xl);
  }

  .-voters {
    @include ftsize(sm);
    font-style: italic;
    line-height: 1rem;
    // max-width: 3.5rem;
    @include fgcolor(tert);
    @include clamp($width: null);
  }

  .-cover {
    height: 100%;
    width: 4rem;
  }

  .link {
    font-weight: 500;
    // padding: 0.375rem 0;
    flex-shrink: 1;

    color: inherit;
    // @include fgcolor(tert);
    @include clamp($width: null);
    // prettier-ignore
    &:hover { @include fgcolor(primary, 5); }
  }
</style>
