<script context="module" lang="ts">
  let stats = {
    mt_ai: 2,
    mtran: 2,
  }
</script>

<script lang="ts">
  import { data } from '$lib/stores/lookup_stores'
  import { copy_to_clipboard } from '$utils/btn_utils'

  import {
    gen_ctree_html,
    gen_mt_ai_html,
    gen_mt_ai_text,
    gen_ctree_text,
  } from '$lib/mt_data_2'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Viewbox from './Viewbox.svelte'

  export let l_idx = 0
  export let stale = false

  $: mt_ai = $data.mt_ai[l_idx]
  let show_zh = false
</script>

<Viewbox
  title="Cây ngữ pháp:"
  bind:state={stats.mt_ai}
  class="cdata _ct"
  --lc="10">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Hiển thị nghĩa tiếng Việt/tiếng Trung gốc"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!mt_ai}
      on:click={() => (show_zh = !show_zh)}>
      <SIcon name="letter-{show_zh ? 'z' : 'v'}" />
    </button>

    <button
      type="button"
      class="-btn"
      data-tip="Sao chép cây ngữ pháp vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!mt_ai}
      on:click={() => copy_to_clipboard(gen_ctree_text(mt_ai))}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>
  {#if mt_ai}
    {@html gen_ctree_html(mt_ai, show_zh)}
  {:else}
    <p class="blank">Chưa có cây ngữ pháp</p>
  {/if}
</Viewbox>

<Viewbox title="Kết quả dịch:" bind:state={stats.mtran} class="cdata" --lc="5">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      on:click={() => (stale = true)}
      data-tip="Dịch lại sau khi đã thay đổi nghĩa của từ"
      data-tip-loc="bottom"
      data-tip-pos="right">
      <SIcon name="refresh-dot" />
    </button>

    <button
      type="button"
      class="-btn"
      data-tip="Sao chép dịch máy vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!mt_ai}
      on:click={() => copy_to_clipboard(gen_mt_ai_text(mt_ai))}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>
  {#if mt_ai}
    {@html gen_mt_ai_html(mt_ai, { mode: 2, cap: true, und: true, _qc: 0 })}
  {:else}
    <p class="blank">Chưa có kết quả dịch máy</p>
  {/if}
</Viewbox>

<style lang="scss">
  .blank {
    @include flex-ca;
    gap: 0.25rem;
    height: 100%;
    padding: 0.25rem 0;
  }
</style>
