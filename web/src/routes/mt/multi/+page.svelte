<script lang="ts" context="module">
  import { browser } from '$app/environment'
  const cache = new Map<string, Rdline>()
</script>

<script lang="ts">
  import { afterNavigate } from '$app/navigation'

  import { Rdline } from '$lib/reader'
  import Wpanel from '$gui/molds/Wpanel.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  $: rline = cache.get(data.input) || new Rdline(data.input)
  $: cache.set(data.input, rline)

  let m_alg = data.m_alg

  afterNavigate(() => {
    m_alg = data.m_alg
  })

  let mtran_state = 0

  const switch_mtran_algo = async (new_algo: string) => {
    if (new_algo == m_alg) return
    m_alg = new_algo
    mtran_state = 0
  }

  const mtran_algos = [
    ['mtl_1', 'Dùng model Electra Small'],
    ['mtl_2', 'Dùng model Electra Base'],
    ['mtl_3', 'Dùng model Ernie Gram'],
  ]

  const load_qtran = (qtype: string) => {
    return async (rmode = 1) => {
      return await rline.load_qtran(rmode, qtype)
    }
  }

  const load_mtran = (mtype: string) => {
    return async (rmode = 1) => {
      await rline.load_mtran(rmode, mtype, data.pdict)
      return rline.mtran_text(m_alg)
    }
  }
</script>

<header>
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
      title="Dịch bằng Baidu:"
      class="_big"
      wdata={rline.qtran['bd_zv']}
      loader={load_qtran('bd_zv')} />

    <Wpanel
      class="_big"
      title="Máy dịch Chivi mới:"
      wdata={rline.mtran_text(m_alg)}
      bind:state={mtran_state}
      loader={load_mtran(m_alg)}>
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
        <button class="m-btn _xs _primary" on:click={() => (mtran_state = 0)}>
          <span>Gọi máy dịch!</span>
        </button>
      </div>
    </Wpanel>

    <Wpanel
      class="_big"
      title="Dịch bằng Google:"
      wdata={rline.qtran['gg_zv']}
      loader={load_qtran('gg_zv')} />
    <Wpanel
      class="_big"
      title="Dịch bằng Bing:"
      wdata={rline.qtran['ms_zv']}
      loader={load_qtran('ms_zv')} />

    <Wpanel
      class="_big"
      title="GPT Tiên hiệp:"
      wdata={rline.qtran['c_gpt']}
      loader={load_qtran('c_gpt')} />

    <Wpanel
      class="_big"
      title="Máy dịch Chivi cũ:"
      loader={load_qtran('qt_v1')} />
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
