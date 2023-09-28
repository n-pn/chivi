<script lang="ts">
  import { ctrl, data } from '$lib/stores/lookup_stores'
  import {
    gen_vtran_html,
    gen_ztext_html,
    gen_ctree_html,
    gen_ctree_text,
    gen_vtran_text,
  } from '$lib/mt_data_2'

  import {
    call_btran_file,
    call_mtran_file,
    from_custom_gpt,
  } from '$utils/tran_util'

  import {
    data as vtform_data,
    ctrl as vtform_ctrl,
  } from '$lib/stores/vtform_stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import Window from './Sideline/Window.svelte'
  import VitermForm from '$gui/parts/VitermForm.svelte'

  import { invalidate } from '$app/navigation'
  import { page } from '$app/stores'
  export let l_idx = 0
  export let l_max = 0

  let zfrom = 0
  let zupto = 1

  $: ztext = $data.ztext[l_idx]
  $: hviet = $data.hviet[l_idx]
  $: ctree = $data.ctree[l_idx]
  $: btran = $data.btran[l_idx]
  $: qtran = $data.qtran[l_idx]
  $: c_gpt = $data.c_gpt[l_idx]

  const node_names = ['X-N', 'X-C', 'X-Z']
  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return

    zfrom = +target.dataset.b
    zupto = +target.dataset.e
    const icpos = target.dataset.c || 'X'

    vtform_data.put(ztext, hviet, ctree, zfrom, zupto, icpos)
    vtform_ctrl.show(0)
  }

  $: finit = {
    fpath: $data.fpath,
    ftype: $data.ftype,
    pdict: $data.pdict,
    m_alg: $data.m_alg,
    force: true,
  }

  const rinit = { no: 'force-cache' } as RequestInit

  const load_btran_data = async () => {
    const btran = await call_btran_file(finit, rinit)

    if (btran.error) alert(btran.error)
    $data.btran = btran.lines || []
  }

  const load_c_gpt_data = async () => {
    const vtext = await from_custom_gpt(ztext)
    $data.c_gpt[l_idx] = vtext
  }

  const load_ctree_data = async () => {
    if ($page.data.xargs?.rtype != 'ai') {
      const ctree = await call_mtran_file(finit, rinit)
      $data.ctree = ctree.lines || []
    } else {
      await invalidate('wn:cdata')
      $data.ctree = $page.data.vtran.lines
    }
  }

  const on_term_change = async (term?: CV.Vtdata | boolean) => {
    if (!term) return
    await load_ctree_data()
  }

  const copy_to_clipboard = (text: string) => {
    navigator.clipboard.writeText(text)
  }

  let ctree_show_zh = false
</script>

<Slider
  class="lookup"
  _sticky={true}
  bind:actived={$ctrl.actived}
  --slider-width="30rem">
  <svelte:fragment slot="header-left">
    <div class="-text">Phân tích</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button
      type="button"
      class="-btn"
      data-kbd="↑"
      disabled={l_idx == 0}
      on:click={() => (l_idx -= 1)}
      data-tip="Chuyển lên dòng trên"
      data-tip-loc="bottom">
      <SIcon name="arrow-up" />
    </button>
    <button
      type="button"
      class="-btn"
      data-kbd="↓"
      on:click={() => (l_idx += 1)}
      disabled={l_idx + 1 == l_max}
      data-tip="Chuyển xuống dòng dưới"
      data-tip-loc="bottom">
      <SIcon name="arrow-down" />
    </button>
  </svelte:fragment>

  {#if l_idx < l_max}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <section class="cbody" on:click={handle_click}>
      <Window title="Tiếng Trung" class="_zh _lg" --lc="2">
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
      </Window>

      <Window title="Ngữ pháp:" class="cdata _ct" --lc="3">
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
      </Window>

      <Window title="Dịch máy:" class="cdata" --lc="4">
        <svelte:fragment slot="tools">
          <button
            type="button"
            class="-btn"
            on:click={() => on_term_change(true)}
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
      </Window>

      <Window title="Bing Translation:" class="_bv _sm" --lc="3">
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
              >Dịch từ Bing Edge!</button>
          </div>
        {/if}
      </Window>

      <Window title="Dịch GPT Tiên hiệp:" class="_vi _sm" --lc="3">
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
      </Window>

      <Window title="Dịch máy cũ:" class="_qt _sm" --lc="3">
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
      </Window>
    </section>
  {:else}
    <div class="empty">Bấm vào đoạn văn để xem giải nghĩa!</div>
  {/if}
</Slider>

{#if $vtform_ctrl.actived}
  <VitermForm
    pdict={$data.pdict}
    fpath={$data.fpath}
    ftype={$data.ftype}
    on_close={on_term_change} />
{/if}

<style lang="scss">
  .cbody {
    padding: 0 0.75rem;

    :global(.cdata._ct x-n) {
      color: var(--active);
      font-weight: 450;
      border: 0;
      &:hover {
        border-bottom: 1px solid var(--border);
      }
    }
  }

  .blank {
    @include flex-ca;
    gap: 0.25rem;
    height: 100%;
    padding: 0.25rem 0;
  }
</style>
