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
      wdata={rline.trans['bd_zv'].toString()}
      loader={rline.text_get_fn('bd_zv', data)} />

    <Wpanel
      class="_big"
      title="Máy dịch Chivi mới:"
      wdata={rline.mtran_text(m_alg)}
      bind:state={mtran_state}
      loader={rline.text_get_fn(m_alg, data)}>
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
      wdata={rline.trans['gg_zv'].toString()}
      loader={rline.text_get_fn('gg_zv', data)} />
    <Wpanel
      class="_big"
      title="Dịch bằng Bing:"
      wdata={rline.trans['ms_zv'].toString()}
      loader={rline.text_get_fn('ms_zv', data)} />

    <Wpanel
      class="_big"
      title="GPT Tiên hiệp:"
      wdata={rline.trans['c_gpt'].toString()}
      loader={rline.text_get_fn('c_gpt', data)} />

    <Wpanel class="_big" title="Máy dịch Chivi cũ:" loader={rline.text_get_fn('qt_v1', data)} />
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
