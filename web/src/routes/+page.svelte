<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import WncritList from '$gui/parts/review/WncritList.svelte'
  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'
  import RmstemCard from '$gui/parts/rmstem/RmstemCard.svelte'
  import UpstemCard from '$gui/parts/upstem/UpstemCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  const rmhosts = [
    '69xinshu.com',
    'biqu5200.net',
    'biqugee.com',
    'biquluo.cc',
    'bxwx.net',
    'bxwxorg.com',
    'duokanba.com',
    'hetushu.com',
    'jx.la',
    'nofff.com',
    'paoshu8.com',
    'piaotia.com',
    'rengshu.com',
    'shubaow.net',
    'tasim.net',
    'uukanshu.com',
    'xbiquge.bz',
    'zsdade.com',
    'zxcs.me',
  ]
</script>

<section class="article island">
  <header class="head m-flex">
    <h2 class="h3">Thư viện truyện chữ</h2>
    <a class="m-viewall u-right" href="/wn">Xem tất cả</a>
  </header>

  <WninfoList books={data.books} />
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
  <div class="m-chips">
    {#each rmhosts as rmhost}
      <a class="m-chip _success" href="/rm/!{rmhost}">{rmhost}</a>
    {/each}
  </div>
</section>

<section class="article island">
  <header class="head m-flex _cy m-flex">
    <h2 class="h3">Đánh giá truyện chữ</h2>
    <a class="m-viewall u-right" href="/uc/crits">Xem tất cả</a>
  </header>

  <WncritList vdata={data.vcrit} ydata={data.ycrit} pager={undefined} show_book={true} _mode={0} />
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
  .article {
    margin-top: var(--gutter);
    padding-bottom: 1rem;
  }

  .head {
    align-items: baseline;
    margin: 0.75rem 0 0.5rem;
  }
</style>
