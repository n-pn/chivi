<script lang="ts" context="module">
  import { browser } from '$app/environment'
  const cache = new Map<string, Rdline>()
</script>

<script lang="ts">
  import { gen_mt_ai_html } from '$lib/mt_data_2'

  import { Rdline } from '$lib/reader'
  import Wpanel from '$gui/molds/Wpanel.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let rline = new Rdline(data.input)
  let mtran_state = 0

  const redo_translation = () => {
    rline = new Rdline(data.input)
    mtran_state = 0
  }

  const switch_mtran_algo = async (new_algo: string) => {
    if (new_algo == data.mtype) return
    data.mtype = new_algo
    mtran_state = 0
  }

  const mtran_algos = [
    ['mtl_1', 'Dùng model Electra Small'],
    ['mtl_2', 'Dùng model Electra Base'],
    ['mtl_3', 'Dùng model Ernie Gram'],
  ]

  const load_qtran = (qkind: string) => {
    return async (rmode = 1) => {
      const qdata = await rline.load_qtran(rmode, qkind, data)
      if (typeof qdata == 'string') return qdata
      return gen_mt_ai_html(qdata, 2)
    }
  }

  // const autoresize = (elem: HTMLElement) => {
  //   const onchange = () => {
  //     let height = elem.scrollHeight
  //     if (height < elem.clientHeight) height = elem.clientHeight
  //     elem.style.height = `${height}px`
  //   }

  //   elem.addEventListener('keyup', onchange, true)
  //   elem.addEventListener('change', onchange, true)

  //   return {
  //     destroy: () => {
  //       elem.removeEventListener('keyup', onchange)
  //       elem.removeEventListener('change', onchange)
  //     },
  //   }
  // }
</script>

<div class="input">
  <input
    class="m-input"
    name="zh"
    placeholder="Nhập tiếng Trung dịch nhanh"
    bind:value={data.input} />
  <button class="m-btn _primary _fill" on:click={() => redo_translation()}>
    <SIcon name="bolt" />
    <span class="u-show-pl">Dịch</span>
  </button>
</div>

{#if browser && data.input}
  {#key rline}
    <Wpanel
      class="_big"
      title="Máy dịch Chivi mới:"
      lines={5}
      wdata={rline.mtran_text(data.mtype)}
      loader={load_qtran(data.mtype)}
      bind:state={mtran_state}>
      <svelte:fragment slot="tools">
        {#each mtran_algos as [algo, hint], index}
          <button
            type="button"
            class="-btn"
            class:_active={data.mtype == algo}
            on:click={() => switch_mtran_algo(algo)}
            data-tip={hint}
            data-tip-loc="bottom"
            data-tip-pos="right">
            <SIcon name="letter-v" />
            <SIcon name="number-{index + 1}" />
          </button>
        {/each}
      </svelte:fragment>
      {@html rline.mtran_html(data.mtype)}
    </Wpanel>

    <Wpanel
      title="Dịch bằng Baidu:"
      class="_big"
      lines={5}
      wdata={rline.qtran_text('bd_zv')}
      loader={rline.text_get_fn('bd_zv', data)} />

    <Wpanel
      title="GPT Tiên hiệp:"
      class="_big"
      lines={5}
      wdata={rline.qtran_text('c_gpt')}
      loader={rline.text_get_fn('c_gpt', data)} />

    <Wpanel
      class="_big"
      lines={5}
      title="Dịch bằng Google:"
      wdata={rline.qtran_text('gg_zv')}
      loader={rline.text_get_fn('gg_zv', data)} />

    <Wpanel
      title="Dịch bằng Bing:"
      class="_big"
      lines={5}
      wdata={rline.qtran_text('ms_zv')}
      loader={rline.text_get_fn('ms_zv', data)} />

    <Wpanel
      title="Dịch máy cũ:"
      class="_big"
      lines={5}
      wdata={rline.qtran_text('qt_v1')}
      loader={rline.text_get_fn('qt_v1', data)} />
  {/key}
{:else}
  <div class="d-empty-sm">
    <em>Nhập tiếng Trung để dịch nhanh</em>
  </div>
{/if}

<style lang="scss">
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
  textarea {
    margin: 0.75rem 0;
    display: block;
    font-size: rem(15px);
  }
</style>
