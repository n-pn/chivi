<script lang="ts">
  import { ctrl, data } from '$lib/stores/lookup_stores'
  import {
    gen_vtran_html,
    gen_ztext_html,
    gen_ctree_html,
    gen_ctree_text,
  } from '$lib/mt_data_2'

  import { get_nctext_btran, get_nctext_mtran } from '$utils/tran_util'

  import {
    data as vtform_data,
    ctrl as vtform_ctrl,
  } from '$lib/stores/vtform_stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import VitermForm from '$gui/parts/VitermForm.svelte'
  import { invalidate } from '$app/navigation'

  export let l_idx = 0
  export let l_max = 0

  let zfrom = 0
  let zupto = 1

  $: ztext = $data.ztext[l_idx]
  $: hviet = $data.hviet[l_idx]
  $: ctree = $data.ctree[l_idx]
  $: btran = $data.btran[l_idx]
  $: qtran = $data.qtran[l_idx]

  const node_names = ['X-N', 'X-C', 'X-Z']
  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return

    zfrom = +target.dataset.b
    zupto = +target.dataset.e
    const icpos = target.dataset.c || 'X'

    vtform_data.put(ztext, hviet, ctree, zfrom, zupto, icpos)
    vtform_ctrl.show(0)
  }

  const load_btran_data = async () => {
    const btran = await get_nctext_btran($data.zpath, true, 'no-cache')
    if (btran.error) alert(btran.error)
    $data.btran = btran.lines || []
  }

  const load_ctree_data = async () => {
    const { zpath, m_alg } = $data
    const ctree = await get_nctext_mtran(zpath, true, m_alg, 'no-cache')
    $data.ctree = ctree.lines || []
  }

  const copy_ctree = () => {
    navigator.clipboard.writeText(gen_ctree_text(ctree))
  }

  const on_term_change = async (term?: CV.Vtdata | boolean) => {
    if (!term) return
    await load_ctree_data()
    await invalidate('wn:cdata')
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
      disabled={l_idx == l_max}
      data-tip="Chuyển xuống dòng dưới"
      data-tip-loc="bottom">
      <SIcon name="arrow-down" />
    </button>
  </svelte:fragment>

  {#if l_idx < l_max}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <section class="cbody" on:click={handle_click}>
      <h4 class="label">Tiếng Trung:</h4>

      <div class="cdata _zh" lang="zh">
        {#if ztext && hviet}
          {@html gen_ztext_html(ztext, hviet)}
        {:else}
          <p class="empty">Chưa có tiếng trung!</p>
        {/if}
      </div>

      <h4 class="label">
        <span class="title">Cây ngữ pháp:</span>
        <span class="tools">
          <label class="radio" data-tip="Hiển thị nghĩa tiếng Việt">
            <input type="radio" bind:group={ctree_show_zh} value={false} />
            <span>Nghĩa</span>
          </label>

          <label class="radio" data-tip="Hiển thị tiếng Trung gốc">
            <input type="radio" bind:group={ctree_show_zh} value={true} />
            <span>Trung</span>
          </label>

          <button type="button" class="tools-btn" on:click={copy_ctree}
            >Sao chép</button>
        </span>
      </h4>
      <div class="cdata debug _ct">
        {#if ctree}
          {@html gen_ctree_html(ctree, ctree_show_zh)}
        {:else}
          <p class="empty">Chưa có cây ngữ pháp</p>
        {/if}
      </div>

      <h4 class="label">
        <span class="title">Dịch máy:</span>
        <span class="tools">
          <button
            type="button"
            class="tools-btn"
            on:click={() => on_term_change(true)}
            data-tip="Dịch lại sau khi đã thay đổi nghĩa của từ"
            >Dịch lại</button>
        </span>
      </h4>

      <div class="cdata debug _mt">
        {#if ctree}
          {@const opts = { mode: 2, cap: true, und: true, _qc: 0 }}
          {@html gen_vtran_html(ctree, opts)}
        {:else}
          <p class="empty">Chưa có kết quả dịch máy</p>
        {/if}
      </div>

      <h4 class="label">Bing Edge:</h4>
      <div class="cdata debug _tl">
        {#if btran}
          {btran}
        {:else}
          <div class="blank">
            <div>
              <em>Chưa có kết quả dịch sẵn.</em>
            </div>
            <button class="m-btn _sm _primary" on:click={load_btran_data}
              >Dịch từ Bing Edge!</button>
          </div>
        {/if}
      </div>
    </section>
  {:else}
    <div class="empty">Bấm vào đoạn văn để xem giải nghĩa!</div>
  {/if}
</Slider>

{#if $vtform_ctrl.actived}
  <VitermForm pdict={$data.pdict} on_close={on_term_change} />
{/if}

<style lang="scss">
  .cbody {
    padding: 0 0.75rem;
  }

  .cdata {
    padding: 0.25rem 0.5rem;

    text-align: justify;
    text-justify: auto;

    @include bgcolor(tert);

    @include border;
    @include bdradi;
    @include scroll;

    &._zh {
      $line: 1.5rem;
      line-height: $line;
      max-height: $line * 3 + 0.75rem;
      @include ftsize(lg);
    }

    &._mt {
      $line: 1.25rem;
      line-height: $line;
      max-height: $line * 6 + 0.75rem;
      font-size: rem(17px);
    }

    &._tl {
      $line: 1.125rem;
      line-height: $line;
      max-height: $line * 5 + 0.75rem;
      font-size: rem(15px);
    }

    &._ct {
      $line: 1.25rem;
      line-height: $line;
      overflow-y: visible;

      :global(x-n) {
        color: var(--active);
        font-weight: 450;
        border: 0;
        &:hover {
          border-bottom: 1px solid var(--border);
        }
      }
    }
  }

  .label {
    display: flex;

    margin-top: 0.5rem;
    margin-bottom: 0.25rem;

    // padding: 0 0.75rem;
    font-weight: 500;
    line-height: 1rem;

    @include ftsize(sm);

    > .tools {
      margin-left: auto;
    }
  }

  .tools-btn {
    background: none;
    color: currentColor;
    font-style: italic;
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .blank {
    @include flex-ca;
    flex-direction: column;
    gap: 0.25rem;
    height: 100%;
    padding: 0.25rem 0;
  }
</style>
