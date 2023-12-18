<script lang="ts">
  import { map_status } from '$utils/nvinfo_utils'
  import { rel_time } from '$utils/time_utils'

  import { SIcon, BCover } from '$gui'

  export let book: CV.Crbook | CV.Wninfo

  $: genres = book.genres || []
</script>

<section class="book">
  <a class="cover" href="/wn/{book.bslug}">
    <BCover srcset={book.bcover} _class="square" />
  </a>

  <div class="info">
    <a class="m-meta title" href="/wn/{book.bslug}">{book.vtitle} </a>

    <div class="extra">
      <a class="m-meta link" href="/wn/={book.vauthor}">
        <SIcon name="edit" />
        <span>{book.vauthor}</span>
      </a>

      <a class="m-meta link" href="/wn/~{genres[0]}">
        <SIcon name="folder" />
        <span>{genres[0]}</span>
      </a>
    </div>
    <div class="extra">
      <span class="m-meta">
        <SIcon name="activity" />
        <span>{map_status(book.status)}</span>
      </span>

      <span class="m-meta">
        <SIcon name="clock" />
        <span>{rel_time(book.mftime)}</span>
      </span>
    </div>
  </div>

  <div class="vote">
    {#if book.voters > 0}
      <div class="rating" data-tip="Đánh giá">{book.rating}</div>
      <div class="voters" data-tip="Lượt đánh giá" data-tip-loc="bottom">
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

  .info {
    overflow: hidden;
  }

  .vote {
    min-width: 3.5rem;
    margin-left: auto;
    margin-right: 0.5rem;
    flex-direction: column;
    @include flex-ca;
  }

  .title,
  .extra {
    @include flex($gap: 0.5rem);
    line-height: 1.5rem;
  }

  .title {
    @include clamp($width: null);

    font-weight: 500;
    margin: 0.25rem 0;

    @include bps(font-size, rem(15px), $pm: rem(16px), $ts: rem(17px));

    @include fgcolor(secd);

    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  .extra {
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .rating {
    font-weight: 500;
    margin-bottom: 0.25rem;
    @include ftsize(xl);
  }

  .voters {
    @include ftsize(sm);
    font-style: italic;
    line-height: 1rem;
    // max-width: 3.5rem;
    @include fgcolor(tert);
    @include clamp($width: null);
  }

  .cover {
    height: 100%;
    width: 4rem;
  }

  .link {
    font-weight: 500;
    flex-shrink: 1;

    color: inherit;
    @include clamp($width: null);
  }
</style>
