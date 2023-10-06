<script context="module" lang="ts">
  let stats = {
    ztext: 1,
    mtran: 2,
    vtran: 2,
    bt_zv: 1,
    c_gpt: 1,
    qt_v1: 1,
  }
</script>

<script lang="ts">
  import { data } from '$lib/stores/lookup_stores'
  import { copy_to_clipboard } from '$utils/btn_utils'

  import {
    gen_mt_ai_html,
    gen_ztext_html,
    gen_mt_ai_text,
  } from '$lib/mt_data_2'

  import { call_bt_zv_file, from_custom_gpt } from '$utils/tran_util'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Viewbox from './Viewbox.svelte'

  export let l_idx = 0
  export let stale = false

  $: ztext = $data.ztext[l_idx]
  $: mt_ai = $data.mt_ai[l_idx]
  $: bt_zv = $data.bt_zv[l_idx]
  $: qt_v1 = $data.qt_v1[l_idx]
  $: c_gpt = $data.c_gpt[l_idx]

  let vtran = ''

  $: finit = { ...$data.ropts, force: true }

  const rinit = { cache: 'no-cache' } as RequestInit

  const load_bt_zv_data = async () => {
    const bt_zv_res = await call_bt_zv_file(finit, rinit)
    if (bt_zv_res.error) alert(bt_zv_res.error)
    $data.bt_zv = bt_zv_res.lines || []
  }

  const load_c_gpt_data = async () => {
    const vtext_res = await from_custom_gpt(ztext)
    $data.c_gpt[l_idx] = vtext_res
  }
</script>

<Viewbox title="Tiếng Trung" bind:state={stats.ztext} class="_zh _lg" --lc="2">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      disabled={!ztext}
      data-tip="Sao chép text gốc vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      on:click={() => copy_to_clipboard(ztext)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if ztext}
    {@html gen_ztext_html(ztext)}
  {:else}
    <p class="empty">Chưa có tiếng trung!</p>
  {/if}
</Viewbox>

<Viewbox title="Dịch máy mới:" bind:state={stats.mtran} class="cdata" --lc="5">
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
    {@const opts = { mode: 2, cap: true, und: true, _qc: 0 }}
    {@html gen_mt_ai_html(mt_ai, opts)}
  {:else}
    <p class="empty">Chưa có kết quả dịch máy</p>
  {/if}
</Viewbox>

<Viewbox title="Dịch thủ công:" bind:state={stats.vtran} class="_vi" --lc="4">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Sao chép bản dịch vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!vtran}
      on:click={() => copy_to_clipboard(vtran)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if vtran}
    {vtran}
  {:else}
    <div class="blank">
      <em>Chưa có kết quả dịch sẵn.</em>
      <button class="m-btn _xs _primary">Đóng góp!</button>
    </div>
  {/if}
</Viewbox>

<Viewbox title="Dịch bằng Bing:" bind:state={stats.bt_zv} class="_sm" --lc="3">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Sao chép bản dịch vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!bt_zv}
      on:click={() => copy_to_clipboard(bt_zv)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if bt_zv}
    {bt_zv}
  {:else}
    <div class="blank">
      <div>
        <em>Chưa có kết quả dịch sẵn.</em>
      </div>
      <button class="m-btn _xs _primary" on:click={load_bt_zv_data}
        >Dịch bằng Bing!</button>
    </div>
  {/if}
</Viewbox>

<Viewbox title="GPT Tiên hiệp:" bind:state={stats.c_gpt} class="_sm" --lc="3">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Sao chép bản dịch vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!c_gpt}
      on:click={() => copy_to_clipboard(c_gpt)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if c_gpt}
    {c_gpt}
  {:else}
    <div class="blank">
      <div>
        <em>Chưa có kết quả dịch sẵn.</em>
      </div>
      <button class="m-btn _xs _primary" on:click={load_c_gpt_data}
        >Gọi công cụ!</button>
    </div>
  {/if}
</Viewbox>

<Viewbox title="Dịch máy cũ:" bind:state={stats.qt_v1} class="_sm" --lc="3">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Sao chép bản dịch vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!qt_v1}
      on:click={() => copy_to_clipboard(qt_v1)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if qt_v1}
    {qt_v1}
  {:else}
    <div class="blank">
      <em>Chưa có kết quả dịch sẵn.</em>
    </div>
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
