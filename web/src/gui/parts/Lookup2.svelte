<script lang="ts">
  import { ctrl, data, get_btran } from '$lib/stores/lookup_stores'
  import { render_vdata, render_ztext, render_ctree } from '$lib/mt_data_2'

  import {
    data as vtform_data,
    ctrl as vtform_ctrl,
  } from '$lib/stores/vtform_stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'
  import VitermForm from '$gui/parts/VitermForm.svelte'

  let zfrom = 0
  let zupto = 1

  const node_names = ['X-N', 'X-C', 'X-Z']
  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return

    zfrom = +target.dataset.b
    zupto = +target.dataset.e
    const icpos = target.dataset.c || '_'

    vtform_data.put($data.hviet, $data.cdata, zfrom, zupto, icpos)
    vtform_ctrl.show(0)
  }

  const call_btran = async () => {
    $data.btran = await get_btran($data.zpath, $data.l_idx, true)
  }

  const copy_ctree = () => {
    navigator.clipboard.writeText(render_ctree($data.cdata, 0))
  }

  const reload_ctree = async () => {
    const text_headers = { 'Content-Type': 'text/plain' }

    const url = '/_ai/mt/reload?pdict=' + $data.pdict
    const body = render_ctree($data.cdata, 0)
    const init = { method: 'POST', body, headers: text_headers }

    const res = await fetch(url, init)
    if (!res.ok) return alert(await res.text())

    const { lines } = await res.json()

    $data.cdata = lines[0]
  }

  const on_term_change = (term?: CV.Viterm) => {
    if (!term) return
    reload_ctree()
  }
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
      on:click={data.move_up}
      data-tip="Chuyển lên dòng trên"
      data-tip-loc="bottom">
      <SIcon name="arrow-up" />
    </button>
    <button
      type="button"
      class="-btn"
      data-kbd="↓"
      on:click={data.move_down}
      data-tip="Chuyển xuống dòng dưới"
      data-tip-loc="bottom">
      <SIcon name="arrow-down" />
    </button>
  </svelte:fragment>

  {#if $data.ztext}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <section class="cbody" on:click={handle_click}>
      <h4 class="label">Tiếng Trung:</h4>

      <div class="cdata _zh" lang="zh">
        {@html render_ztext($data.cdata, 2)}
      </div>

      <h4 class="label">
        <span class="title">Cây ngữ pháp:</span>
        <span class="tools">
          <button type="button" class="tools-btn" on:click={copy_ctree}
            >Sao chép</button>
        </span>
      </h4>
      <div class="cdata debug _ct">
        {@html render_ctree($data.cdata, 2)}
      </div>

      <h4 class="label">
        <span class="title">Dịch máy:</span>
        <span class="tools">
          <button
            type="button"
            class="tools-btn"
            on:click={reload_ctree}
            data-tip="Dịch lại sau khi đã thay đổi nghĩa của từ"
            >Dịch lại</button>
        </span>
      </h4>

      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <div class="cdata debug _mt">
        {#if $data.cdata}
          {@html render_vdata($data.cdata, 2)}
        {/if}
      </div>

      <h4 class="label">Bing Edge:</h4>
      <div class="cdata debug _tl">
        {#if $data.btran}
          {$data.btran}
        {:else}
          <div class="blank">
            <div>
              <em>Chưa có kết quả dịch sẵn.</em>
            </div>
            <button class="m-btn _sm _primary" on:click={call_btran}
              >Dịch từ Bing Edge!</button>
          </div>
        {/if}
      </div>

      <h4 class="label">Hán Việt:</h4>
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <div class="cdata debug _hv">
        {@html render_vdata($data.hviet, 2)}
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

    &._hv {
      $line: 1.125rem;
      line-height: $line;
      max-height: $line * 4 + 0.75rem;
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

      :global(x-z) {
        font-weight: 500;
      }

      :global(x-n) {
        border-bottom: none;
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
