<script lang="ts">
  import YscritCard from '$gui/parts/review/YscritCard.svelte'
  import YsreplCard from '$gui/parts/review/YsreplCard.svelte'

  import type { PageData } from './$types'
  export let data: PageData
</script>

<YscritCard {...data.ydata} view_all={true} big_text={true} />

<section id="repls" class="repls island">
  <h3>Phản hồi đánh giá <span class="count">({data.ydata.crit.repl_count})</span>:</h3>

  {#each data.repls as yrepl}
    <YsreplCard {yrepl} />
  {:else}
    <div class="d-empty-sm">Không có phản hồi.</div>
  {/each}
</section>

<style lang="scss">
  .repls {
    @include padding-x(var(--gutter));
  }

  h3 {
    margin-top: 0.5rem;
    margin-bottom: 0.5rem;
  }
</style>
