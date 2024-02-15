<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import Truncate from '$gui/atoms/Truncate.svelte'
  import WninfoList from '$gui/parts/wninfo/WninfoList.svelte'
  import YscritCard from '$gui/parts/review/YscritCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  import { rstate_labels, rstate_colors, rstate_icons, rstate_slugs } from '$lib/consts/rd_states'

  $: ({ nvinfo: binfo, ydata, bdata } = data)

  $: dhtml = binfo.bintro
    .split('\n')
    .map((x) => `<p>${x}</p>`)
    .join('\n')
</script>

<section>
  <h2>Giới thiệu:</h2>
  <div class="intro" class:_short={false}>
    <Truncate html={dhtml} />
  </div>
</section>

<section>
  <header class="sub-head">
    <h3>Các tên khác:</h3>
  </header>

  <div class="m-flex u_gap3">
    <span class="m-iflex u_gap2">
      <span class="u-fg-tert">Gốc Trung: </span>
      <span class="u-fg-main">{binfo.ztitle}</span>
    </span>
    <span class="m-iflex u_gap2">
      <span class="u-fg-tert">Hán Việt:</span>
      <span class="u-fg-main">{binfo.htitle}</span>
    </span>
  </div>
</section>

<section>
  <header class="sub-head">
    <h3>Liên kết ngoài:</h3>
  </header>
  <div class="m-flex _cy u_gap2">
    {#each binfo.origins as { name, link, type }}
      <a class="tag" href={link} rel="noreferrer" target="_blank">{name}</a>
      {#if type == 1}
        <a class="u-fg-tert" href="/wn?from={name}" data-tip="Tìm truyện cùng nguồn"
          ><SIcon name="search" /></a>
      {/if}
    {:else}
      <div class="d-empty-xs">Danh sách trống</div>
    {/each}
  </div>
</section>

<section>
  <header class="sub-head">
    <h3>Từ khóa tìm kiếm</h3>
  </header>

  {#if binfo.labels.length > 0}
    <div class="m-flex u_gap3">
      {#each binfo.labels as label}
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
  <header class="sub-head">
    <h3>Đánh giá nổi bật</h3>
    <a class="m-viewall u-right" href="/wn/{binfo.id}/crits">Xem tất cả</a>
  </header>

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
  <header class="sub-head">
    <h3>Truyện đồng tác giả</h3>
    <a class="m-viewall u-right" href="/wn/={binfo.vauthor}">Xem tất cả</a>
  </header>

  {#if bdata.books.length > 0}
    <WninfoList books={bdata.books} />
  {:else}
    <div class="d-empty-xs">Không có tác phẩm khác</div>
  {/if}
</section>

<section>
  <header class="sub-head">
    <h3>Danh sách độc giả</h3>
  </header>

  {#if bdata.users.length > 0}
    <div class="users">
      {#each bdata.users as { uname, privi, track }}
        {@const query = track >= 0 ? `?st=${rstate_slugs[track]}` : ''}
        <a
          class="m-chip _{rstate_colors[track]}"
          href="/@{uname}/books{query}"
          data-tip={track > 0 ? rstate_labels[track] : 'Chưa đánh dấu'}>
          <cv-user data-privi={privi}>{uname}</cv-user>
          <SIcon name={track > 0 ? rstate_icons[track] : 'eye'} />
        </a>
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

  .sub-head {
    line-height: 2rem;
    height: 2rem;
    margin-bottom: 0.75rem;
    @include flex($gap: 0.5rem);
    @include border(--bd-main, $loc: bottom);
  }

  .tag {
    display: inline-flex;
    align-items: center;
    @include ftsize(lg);
    // margin-right: 0.5rem;
    height: 1.25rem;
    @include fgcolor(primary, 5);

    &:hover {
      text-decoration: underline;
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
