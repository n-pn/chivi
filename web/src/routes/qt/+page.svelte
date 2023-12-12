<script lang="ts" context="module">
  import { browser } from '$app/environment'
  const cache = new Map<string, Rdline>()
  cache.set('', new Rdline(''))
</script>

<script lang="ts">
  import { Rdline } from '$lib/reader'

  import Wpanel from '$gui/molds/Wpanel.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  import { gen_mt_ai_text } from '$lib/mt_data_2'
  import { afterNavigate } from '$app/navigation'
  export let data: PageData

  let rline = new Rdline('')

  let m_alg = data.m_alg
  let mtran_loaded = false

  afterNavigate(() => {
    mtran_loaded = false
    m_alg = data.m_alg

    let input = data.input
    let prev = cache.get(input)

    if (prev) {
      rline = prev
      rline.mt_ai = undefined
    } else {
      rline = new Rdline(input)
      cache.set(input, rline)
    }
  })

  const switch_mtran_algo = async (new_algo: string) => {
    if (new_algo == m_alg) return
    m_alg = new_algo
    mtran_loaded = false
    rline.mt_ai = undefined
  }

  const load_mtran = async (rmode = 2) => {
    const mdata = await rline.load_mtran(rmode, data.pdict, m_alg)
    return gen_mt_ai_text(mdata)
  }

  const mtran_algos = [
    ['mtl_1', 'Dùng model Electra Small'],
    ['mtl_2', 'Dùng model Electra Base'],
    ['mtl_3', 'Dùng model Ernie Gram'],
  ]
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

{#if browser && data.input}
  {#key data.input}
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

    <Wpanel
      class="_big"
      title="Máy dịch Chivi mới:"
      loader={load_mtran}
      bind:loaded={mtran_loaded}>
      <svelte:fragment slot="tools">
        {#each mtran_algos as [algo, hint], index}
          <button
            type="button"
            class="-btn"
            class:_active={m_alg == algo}
            on:click={() => switch_mtran_algo(algo)}
            data-tip={hint}
            data-tip-loc="bottom"
            data-tip-pos="right">
            <SIcon name="letter-v" />
            <SIcon name="number-{index + 1}" />
          </button>
        {/each}
      </svelte:fragment>
      <div class="d-empty-xs" slot="empty">
        <button
          class="m-btn _xs _primary"
          on:click={() => (mtran_loaded = false)}>
          <span>Gọi máy dịch!</span>
        </button>
      </div>
    </Wpanel>

    <Wpanel
      class="_big"
      title="Máy dịch Chivi cũ:"
      loader={rline.load_qt_v1.bind(rline)} />
  {/key}
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
