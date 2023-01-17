<script lang="ts">
  import { status_icons, status_names, status_colors } from '$lib/constants'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import NvinfoList from '$gui/parts/nvinfo/NvinfoList.svelte'
  import YscritCard from '$gui/parts/yousuu/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let nvinfo: CV.Nvinfo

  let books: CV.Nvinfo[]
  let users: { u_dname: string; u_privi: number; _status: string }[]

  $: ({ nvinfo, crits, books, users } = data)

  let short_intro = false
</script>

<article class="m-article">
  <h2>Giới thiệu:</h2>
  <div class="intro" class:_short={short_intro}>
    {@html nvinfo.bintro
      .split('\n')
      .map((x) => `<p>${x}</p>`)
      .join('\n')}
  </div>

  <h3 class="sub">Từ khoá</h3>

  <div class="tags">
    {#each nvinfo.labels as label}
      <a class="tag" href="/books?tagged={label}">
        <SIcon name="hash" />
        <span>{label}</span>
      </a>
    {/each}
  </div>

  <h3 class="sub">
    <sub-label>Đánh giá nổi bật</sub-label>
    <a class="sub-link" href="/-{nvinfo.bslug}/crits">Xem tất cả</a>
  </h3>

  <div class="crits">
    {#each crits as crit}
      {@const view_all = crit.vhtml.length < 640}
      {#key crit.id}
        <YscritCard {crit} book={null} show_book={false} {view_all} />
      {/key}
    {:else}
      <div class="empty">Chưa có đánh giá</div>
    {/each}
  </div>

  <h3 class="sub">
    <sub-label>Truyện đồng tác giả</sub-label>
    <a class="sub-link" href="/books/={nvinfo.author_vi}">Xem tất cả</a>
  </h3>

  {#if books.length > 0}
    <NvinfoList {books} />
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
        href="/books/@{u_dname}/{_status}"
        data-tip="[{status_names[_status]}]">
        <cv-user data-privi={u_privi}>{u_dname}</cv-user>
        <SIcon name={status_icons[_status]} />
      </a>
    {:else}
      <div class="empty">Chưa có người đọc</div>
    {/each}
  </div>
</article>

<style lang="scss">
  article {
    @include bps(margin-left, 0rem, 0.25rem, 1.5rem, 2rem);
    @include bps(margin-right, 0rem, 0.25rem, 1.5rem, 2rem);
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

    > :global(p) {
      margin-top: 0.75rem;
    }
  }

  .sub {
    line-height: 2rem;
    height: 2rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);
  }

  .tag {
    display: inline-flex;
    align-items: center;
    margin-right: 0.5rem;
    line-height: 1.25rem;
    @include fgcolor(primary, 5);
    &:hover {
      @include border(primary, 5, $loc: bottom);
    }
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
