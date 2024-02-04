<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import WncritList from '$gui/parts/review/WncritList.svelte'

  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'

  import RmstemCard from '$gui/parts/rmstem/RmstemCard.svelte'
  import UpstemCard from '$gui/parts/upstem/UpstemCard.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'
  import YscritCard from '$gui/parts/review/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ books } = data)

  const links = [
    ['/mt/qtran', 'language', 'Dịch đoạn văn'],
    ['/mt/qttxt', 'bolt', 'Dịch văn bản'],
    // ['/mt/qturl', 'world', 'Dịch trang web'],
    // ['/mt/qlook', 'search', 'Tra nhanh nghĩa'],
  ]
</script>

<nav class="nav-list">
  {#each links as [href, icon, text]}
    <a {href} class="nav-link">
      <SIcon class="u-show-pm" name={icon} />
      <span>{text}</span>
    </a>
  {/each}
</nav>

<section class="article island">
  <header class="head m-flex">
    <h2 class="h3">Thư viện truyện chữ</h2>
    <a class="m-viewall u-right" href="/wn">Xem tất cả</a>
  </header>

  <WninfoList {books} />
</section>

<section class="article island">
  <header class="head m-flex">
    <h2 class="h3">Sưu tầm cá nhân</h2>
    <a class="m-viewall u-right" href="/up">Xem tất cả</a>
  </header>
  {#each data.ustems as ustem}
    <UpstemCard {ustem} />
  {:else}
    <div class="d-empty-sm">Có lỗi, mời liên hệ ban quản trị.</div>
  {/each}
</section>

<section class="article island">
  <header class="head m-flex">
    <h2 class="h3">Liên kết nhúng ngoài</h2>
    <a class="m-viewall u-right" href="/rm">Xem tất cả</a>
  </header>
  {#each data.rstems as rstem}
    <RmstemCard {rstem} />
  {:else}
    <div class="d-empty-sm">Có lỗi, mời liên hệ ban quản trị.</div>
  {/each}
</section>

<section class="article island">
  <header class="head m-flex _cy m-flex">
    <h2 class="h3">Đánh giá truyện chữ</h2>
    <a class="m-viewall u-right" href="/uc/crits">Xem tất cả</a>
  </header>

  <WncritList vdata={data.vcrit} ydata={data.ycrit} show_book={true} _mode={0} />
</section>

<!--
<section class="list">
  <header class="head m-flex">
    <h2 class="h3">Truyện mới cập nhật</h2>
    <a class="link" href="/wn?order=update">Xem tất cả</a>
  </header>
  <WninfoList books={books.update} />
</section>

<section class="list">
  <header class="head m-flex">
    <h2 class="h3">Tổng hợp cho điểm</h2>
    <a class="link" href="/wn?order=weight">Xem tất cả</a>
  </header>

  <WninfoList books={books.weight} />
</section> -->

<style lang="scss">
  .article + .article {
    margin-top: var(--gutter);
  }

  .head {
    align-items: baseline;
    margin: 0.75rem 0 0.5rem;
  }

  .qtran {
    @include flex-ca;
    margin: 0.75rem 0 1.5rem;
    width: 100%;

    > input {
      flex: 1;
      @include bdradi(0, $loc: right);
      height: 2.25rem;
    }
    > button {
      @include bdradi(0, $loc: left);
      height: 2.25rem;
    }
  }

  .nav-list {
    margin: 1.5rem 0 0.75rem;
  }

  .list {
    margin: 0.75rem 0;
    padding-bottom: 1.5rem;

    &:not(:last-child) {
      @include border(--bd-soft, $loc: bottom);
    }
  }
</style>
