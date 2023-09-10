<script context="module" lang="ts">
  import { writable, get } from 'svelte/store'
  // import { api_call, api_get } from '$lib/api_call'

  import { get_wntext_btran, get_wntext_hviet } from '$utils/tran_util'

  import {
    type Cdata,
    render_cdata,
    render_ztext,
    render_ctree,
  } from '$lib/mt_data_2'

  export const ctrl = {
    ...writable({ actived: false, enabled: true }),
    hide: (enabled = true) => ctrl.set({ enabled, actived: false }),
    show(forced = true) {
      const { enabled, actived } = get(ctrl)
      if (actived || forced || enabled) ctrl.set({ enabled, actived: true })
    },
  }

  // const headers = { 'Content-Type': 'application/json' }

  async function get_hviet(zpath: string, l_idx: number, force = false) {
    const { cdata } = await get_wntext_hviet(zpath, force)
    return cdata[l_idx]
  }

  async function get_btran(zpath: string, l_idx: number, force = false) {
    const { cdata } = await get_wntext_btran(zpath, force)
    return cdata[l_idx]
  }

  export interface Data {
    zpath: string
    pdict: string

    l_idx: number
    l_max: number

    ztext: string
    btran: string

    cdata: Cdata
    hviet: Cdata
  }

  export const data = {
    ...writable<Data>({
      zpath: '',
      pdict: '',
      l_idx: 0,
      l_max: 0,
      ztext: '',
      btran: '',
      cdata: undefined,
      hviet: undefined,
    }),

    async from_cdata(
      lines: Array<Cdata>,
      l_idx: number,
      zpath = '',
      pdict = ''
    ) {
      const l_max = lines.length
      if (l_idx >= l_max) l_idx = l_max - 1

      const cdata = lines[l_idx]
      const ztext = render_ztext(cdata, 0)

      const hviet = await get_hviet(zpath, l_idx)
      const btran = await get_btran(zpath, l_idx)

      data.set({
        zpath,
        pdict,
        l_idx,
        l_max,
        ztext,
        btran,
        cdata,
        hviet,
      })
    },
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Slider from '$gui/molds/Slider.svelte'

  let zfrom = 0
  let zupto = 1

  function handle_click({ target }) {
    if (target.nodeName == 'X-N') zfrom = +target.dataset.b
  }

  const call_btran = async () => {
    $data.btran = await get_btran($data.zpath, $data.l_idx, true)
  }

  const copy_ctree = () => {
    navigator.clipboard.writeText(render_ctree($data.cdata, 0))
  }

  let viewer = null
  // const focused = []

  // function update_focus() {
  //   if (!viewer) return

  //   current = entries[$zfrom] || []
  //   if (current.length == 0) $zupto = $zfrom
  //   else $zupto = $zfrom + +current[0][0]

  //   focused.forEach((x) => x.classList.remove('focus'))
  //   focused.length = 0

  //   for (let idx = $zfrom; idx < $zupto; idx++) {
  //     const nodes = viewer.querySelectorAll(`x-n[data-l="${idx}"]`)

  //     nodes.forEach((x: HTMLElement) => {
  //       focused.push(x)
  //       x.classList.add('focus')
  //       x.scrollIntoView({ block: 'end', behavior: 'smooth' })
  //     })
  //   }
  // }

  const move_up = () => {
    if ($data.l_idx > 0) $data.l_idx -= 1
  }

  const move_down = () => {
    if ($data.l_idx < $data.l_max - 1) $data.l_idx += 1
  }
</script>

<Slider
  class="lookup"
  _sticky={true}
  bind:actived={$ctrl.actived}
  --slider-width="30rem">
  <svelte:fragment slot="header-left">
    <div class="-icon">
      <SIcon name="compass" />
    </div>
    <div class="-text">Giải nghĩa</div>
  </svelte:fragment>

  <svelte:fragment slot="header-right">
    <button type="button" class="-btn" data-kbd="↑" on:click={move_up} />
    <button type="button" class="-btn" data-kbd="↓" on:click={move_down} />
  </svelte:fragment>

  {#if $data.ztext}
    <section class="cbody" bind:this={viewer}>
      <h4 class="label">Tiếng Trung:</h4>
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <div class="cdata _zh" on:click={handle_click} lang="zh">
        {@html render_ztext($data.cdata, 2)}
      </div>

      <h4 class="label">Hán Việt:</h4>
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <div class="cdata debug _hv" on:click={handle_click}>
        {@html render_cdata($data.hviet, 2)}
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

      <h4 class="label">Dịch máy:</h4>
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <div class="cdata debug _mt" on:click={handle_click}>
        {#if $data.cdata}
          {@html render_cdata($data.cdata, 2)}
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
    </section>
  {:else}
    <div class="empty">Bấm vào đoạn văn để xem giải nghĩa!</div>
  {/if}
</Slider>

<style lang="scss">
  .cdata {
    padding: 0.25rem 0.5rem;
    @include bgcolor(tert);
    @include scroll;

    &._zh {
      $line: 1.5rem;
      line-height: $line;
      max-height: $line * 3 + 0.75rem;
      @include ftsize(lg);
      @include border($loc: bottom);
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
      max-height: $line * 10 + 0.75rem;

      :global(x-z) {
        font-weight: 500;
      }
    }
  }

  .label {
    display: flex;
    @include ftsize(sm);
    padding: 0 0.75rem;
    // font-weight: bold;
    line-height: 1rem;

    margin-top: 0.5rem;
    margin-bottom: 0.25rem;

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
