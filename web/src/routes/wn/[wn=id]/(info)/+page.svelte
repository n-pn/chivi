<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import Truncate from '$gui/atoms/Truncate.svelte'
  import GdreplList from '$gui/parts/dboard/GdreplList.svelte'
  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'
  import YscritCard from '$gui/parts/review/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  import {
    status_types,
    status_icons,
    status_names,
    status_colors,
  } from '$lib/constants'

  $: ({ gdroot, rplist, nvinfo, ydata, bdata } = data)

  let short_intro = false
  $: dhtml = nvinfo.bintro
    .split('\n')
    .map((x) => `<p>${x}</p>`)
    .join('\n')
</script>

<section>
  <h2>Giới thiệu:</h2>
  <div class="intro" class:_short={short_intro}>
    <Truncate html={dhtml} />
  </div>
</section>

<section>
  <h3 class="sub">Từ khoá</h3>

  {#if nvinfo.labels.length > 0}
    <div class="tags">
      {#each nvinfo.labels as label}
        <a class="tag" href="/wn?tagged={label}">
          <SIcon name="hash" />
          <span>{label}</span>
        </a>
      {/each}
    </div>
  {:else}
    <div class="d-empty-xs">Không có từ khóa</div>
  {/if}
</section>

<section>
  <h3 class="sub">Bình luận nội dung</h3>
  <GdreplList {gdroot} {rplist} />
</section>

<section>
  <h3 class="sub">
    <sub-label>Đánh giá nổi bật</sub-label>
    <a class="sub-link" href="/wn/{nvinfo.bslug}/uc">Xem tất cả</a>
  </h3>

  <div class="crits">
    {#each ydata.crits as crit}
      {@const list = ydata.lists[crit.list_id]}
      {@const user = ydata.users[crit.user_id]}
      {#key crit.id}
        <YscritCard {crit} {user} {list} book={null} show_book={false} />
      {/key}
    {:else}
      <div class="d-empty-xs">Chưa có đánh giá</div>
    {/each}
  </div>
</section>

<section>
  <h3 class="sub">
    <sub-label>Truyện đồng tác giả</sub-label>
    <a class="sub-link" href="/wn/={nvinfo.vauthor}">Xem tất cả</a>
  </h3>

  {#if bdata.books.length > 0}
    <WninfoList books={bdata.books} />
  {:else}
    <div class="d-empty-xs">Không có tác phẩm khác</div>
  {/if}
</section>

<section>
  <h3 class="sub">
    <sub-label>Danh sách độc giả</sub-label>
  </h3>

  {#if bdata.users.length > 0}
    <div class="users">
      {#each bdata.users as { uname, privi, umark }}
        {@const status = status_types[umark]}
        {#if umark > 0}
          <a
            class="m-chip _{status_colors[status]}"
            href="/@{uname}/books/{status}"
            data-tip="Đánh dấu: {status_names[status]}">
            <cv-user data-privi={privi}>{uname}</cv-user>
            <SIcon name={status_icons[status]} />
          </a>
        {:else}
          <a
            class="m-chip _neutral"
            href="/@{uname}/books/default"
            data-tip="Chưa thêm đánh dấu">
            <cv-user data-privi={privi}>{uname}</cv-user>
            <SIcon name="eye" />
          </a>
        {/if}
      {/each}
    </div>
  {:else}
    <div class="d-empty-xs">Chưa có người đọc</div>
  {/if}
</section>

<style lang="scss">
  .intro {
    word-wrap: break-word;
    // @include bps(padding, $md: 0 0.75rem);
    @include bps(font-size, rem(15px), rem(16px), rem(17px));
  }

  .sub {
    line-height: 2rem;
    height: 2rem;
    margin-bottom: 0.75rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);
  }

  .sub-link {
    margin-left: auto;
    font-style: italic;
    @include ftsize(md);
    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary, 5);
    }
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

  .m-chip {
    gap: 0.25rem;
  }

  .users {
    display: flex;
    gap: 0.25rem;
    flex-wrap: wrap;
  }

  section {
    margin: 1rem 0;
  }
</style>
