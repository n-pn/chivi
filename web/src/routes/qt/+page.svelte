<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  import { btran_word } from '$utils/qtran_utils/btran_free'
  import { gtran_word } from '$utils/qtran_utils/gtran_free'
</script>

<header>
  <h1 class="h2">Dịch nhanh câu văn/cụm từ</h1>

  <form action="/qt" method="GET">
    <div class="input">
      <input
        class="m-input"
        name="zh"
        placeholder="Nhập tiếng Trung dịch nhanh"
        value={data.input} />

      <button type="submit" class="m-btn _primary _fill">
        <SIcon name="bolt" />
        <span class="u-show-pl">Dịch nhanh</span>
      </button>
    </div>
  </form>
</header>

{#if data.input}
  <h2 class="h4">Google Translate</h2>
  {#await gtran_word(data.input)}
    <div class="d-emtpy-xs">
      <SIcon name="loader-2" spin={true} />
      <em>Đang tải</em>
    </div>
  {:then terms}
    <div class="out-list">
      {#each terms as term}
        <div class="out-term">{term}</div>
      {/each}
    </div>
  {/await}

  <h2 class="h4">Bing Translate</h2>
  {#await btran_word(data.input)}
    <div class="d-emtpy-xs">
      <SIcon name="loader-2" spin={true} />
      <em>Đang tải</em>
    </div>
  {:then terms}
    <div class="out-list">
      {#each terms as term}
        <div class="out-term">{term}</div>
      {/each}
    </div>
  {/await}
{:else}
  <div class="d-empty-sm">
    <em>Nhập tiếng Trung để dịch nhanh</em>
  </div>
{/if}

<style lang="scss">
  header {
    margin: 0.75rem 0;
  }

  h1 {
    margin-bottom: 0.75rem;
  }

  h2 {
    margin-top: 0.75rem;
    margin-bottom: 0.25rem;
  }

  .input {
    @include flex;
    // gap: 0.5rem;
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

  .out-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
  }

  .out-term {
    @include bdradi;

    @include bgcolor(main);
    padding: 0.25rem 0.5rem;
  }
</style>
