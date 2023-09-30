<script lang="ts">
  import { data } from '$lib/stores/lookup_stores'
  import { copy_to_clipboard } from '$utils/btn_utils'

  import {
    gen_vtran_html,
    gen_ztext_html,
    gen_ctree_html,
    gen_ctree_text,
    gen_vtran_text,
  } from '$lib/mt_data_2'

  import { call_btran_file, from_custom_gpt } from '$utils/tran_util'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Viewbox from './Viewbox.svelte'

  export let l_idx = 0
  export let reload_ctree = false

  $: ztext = $data.ztext[l_idx]
  $: hviet = $data.hviet[l_idx]
  $: ctree = $data.ctree[l_idx]
  $: btran = $data.btran[l_idx]
  $: qtran = $data.qtran[l_idx]
  $: c_gpt = $data.c_gpt[l_idx]

  $: finit = { ...$data.zpage, m_alg: $data.m_alg, force: true }

  const rinit = { cache: 'no-cache' } as RequestInit

  const load_btran_data = async () => {
    const btran_res = await call_btran_file(finit, rinit)
    if (btran_res.error) alert(btran_res.error)
    $data.btran = btran_res.lines || []
  }

  const load_c_gpt_data = async () => {
    const vtext_res = await from_custom_gpt(ztext)
    $data.c_gpt[l_idx] = vtext_res
  }

  let ctree_show_zh = false
</script>

<Viewbox title="Tiếng Trung" class="_zh _lg" --lc="2">
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
    {@html gen_ztext_html(ztext, hviet || [])}
  {:else}
    <p class="empty">Chưa có tiếng trung!</p>
  {/if}
</Viewbox>

<Viewbox title="Ngữ pháp:" class="cdata _ct" --lc="3">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Hiển thị nghĩa tiếng Việt/tiếng Trung gốc"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!ctree}
      on:click={() => (ctree_show_zh = !ctree_show_zh)}>
      <SIcon name="letter-{ctree_show_zh ? 'z' : 'v'}" />
    </button>

    <button
      type="button"
      class="-btn"
      data-tip="Sao chép cây ngữ pháp vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!ctree}
      on:click={() => copy_to_clipboard(gen_ctree_text(ctree))}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>
  {#if ctree}
    {@html gen_ctree_html(ctree, ctree_show_zh)}
  {:else}
    <p class="empty">Chưa có cây ngữ pháp</p>
  {/if}
</Viewbox>

<Viewbox title="Dịch máy:" class="cdata" --lc="4">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      on:click={() => (reload_ctree = true)}
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
      disabled={!ctree}
      on:click={() => copy_to_clipboard(gen_vtran_text(ctree))}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>
  {#if ctree}
    {@const opts = { mode: 2, cap: true, und: true, _qc: 0 }}
    {@html gen_vtran_html(ctree, opts)}
  {:else}
    <p class="empty">Chưa có kết quả dịch máy</p>
  {/if}
</Viewbox>

<Viewbox title="Bing Translation:" class="_bv _sm" --lc="3">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Sao chép bản dịch vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!btran}
      on:click={() => copy_to_clipboard(btran)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if btran}
    {btran}
  {:else}
    <div class="blank">
      <div>
        <em>Chưa có kết quả dịch sẵn.</em>
      </div>
      <button class="m-btn _xs _primary" on:click={load_btran_data}
        >Dịch bằng Bing!</button>
    </div>
  {/if}
</Viewbox>

<Viewbox title="Dịch GPT Tiên hiệp:" class="_vi _sm" --lc="3">
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

<Viewbox title="Dịch máy cũ:" class="_qt _sm" --lc="3">
  <svelte:fragment slot="tools">
    <button
      type="button"
      class="-btn"
      data-tip="Sao chép bản dịch vào clipboard"
      data-tip-loc="bottom"
      data-tip-pos="right"
      disabled={!qtran}
      on:click={() => copy_to_clipboard(qtran)}>
      <SIcon name="copy" />
    </button>
  </svelte:fragment>

  {#if qtran}
    {qtran}
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
