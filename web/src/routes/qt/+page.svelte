<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  import { Rdline } from '$lib/reader'
  import { btran_text } from '$utils/qtran_utils/btran_free'
  import { gtran_word } from '$utils/qtran_utils/gtran_free'
  import { baidu_word } from '$utils/qtran_utils/baidu_free'

  import Wpanel from '$gui/molds/Wpanel.svelte'

  $: rline = new Rdline(data.input)
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
  <Wpanel
    class="_big"
    title="Dịch bằng Google:"
    loader={rline.load_gtran.bind(rline)} />
  <Wpanel
    class="_big"
    title="Dịch bằng Bing:"
    loader={rline.load_bt_zv.bind(rline)} />

  <Wpanel
    title="Dịch bằng Baidu:"
    class="_big"
    wdata={rline.baidu}
    loader={rline.load_baidu.bind(rline)} />

  <Wpanel
    class="_big"
    title="GPT Tiên hiệp:"
    loader={rline.load_c_gpt.bind(rline)} />
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
</style>
