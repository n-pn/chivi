<script lang="ts">
  import UpstemCard from '$gui/parts/upstem/UpstemCard.svelte'

  import type { PageData } from '../$types'
  import SIcon from '$gui/atoms/SIcon.svelte'
  export let data: PageData

  $: ({ ustems } = data)

  $: rstems = data.seed_list.globs || []
</script>

<section class="section">
  <header class="header">
    <h3>Nguồn dự án cá nhân ({ustems.length})</h3>
    <a class="m-btn _primary _fill _sm" href="/up/+proj?wn={data.nvinfo.id}">
      <SIcon name="file-plus" />
      <span>Tạo mới</span>
    </a>
  </header>

  {#each ustems as ustem}
    <UpstemCard {ustem} />
  {:else}
    <div class="empty">Chưa có dự án cá nhân nào liên kết tới bộ truyện</div>
  {/each}
</section>

<section class="section">
  <header class="header">
    <h3>Nguồn liên kết với bên ngoài ({rstems.length})</h3>
  </header>
</section>

<style lang="scss">
  .header {
    @include flex-cy;
    gap: 0.25rem;
    padding: 0.5rem 0;

    a {
      margin-left: auto;
    }
  }
  .section {
    margin: 1rem;
    @include bp-min(tl) {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  .empty {
    display: flex;
    min-height: 50vh;
    align-items: center;
    justify-content: center;
    font-style: italic;
    @include fgcolor(neutral, 6);
  }
</style>
