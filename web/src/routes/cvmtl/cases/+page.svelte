<script lang="ts">
  import type { PageData } from './$types'

  export let data: PageData
</script>

<div class="list article island">
  {#each data.files as file}
    <a class="item" href="/cvmtl/cases/{file}">{file}</a>
  {/each}
</div>

<style lang="scss">
  .list {
    display: grid;
    gap: 0.5rem;
    grid-template-columns: repeat(3, minmax(5rem, 1fr));
    margin-top: var(--gutter);
    padding: var(--gutter);
  }

  .item {
    display: inline-block;
    line-height: 2rem;
    @include fgcolor(secd);

    @include hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
