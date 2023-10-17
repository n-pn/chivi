<script lang="ts">
  import {
    gen_ctree_html,
    gen_hviet_html,
    gen_mt_ai_html,
  } from '$lib/mt_data_2'

  import Vtform, {
    data as vtform_data,
    ctrl as vtform_ctrl,
  } from '$gui/shared/vtform/Vtform.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let ztext = data.ztext || ''
  let m_alg = data.m_alg || 'mtl_2'
  let pdict = data.pdict || 'combine'

  $: ai_url = `/_ai/debug?pdict=${pdict}&m_alg=${m_alg}`
  $: hv_url = `/_ai/hviet?pdict=${pdict}&m_alg=${m_alg}`

  // prettier-ignore
  let ctree : CV.Cvtree[] = []

  // prettier-ignore
  let hviet : [string,string][][] = []

  const call_debug = async () => {
    const rinit = { body: ztext, method: 'POST' }

    const hdata = await fetch(hv_url, rinit).then((r) => r.json())
    hviet = hdata.hviet

    const vdata = await fetch(ai_url, rinit).then((r) => r.json())
    ctree = vdata.lines

    navigator.clipboard.writeText(vdata.ztree[0])
  }

  const ropts: CV.Rdopts = {
    fpath: '',
    pdict,
    rmode: 'mt',
    mt_rm: m_alg,
    qt_rm: '',
    wn_id: 0,
  }

  const node_names = ['X-N', 'X-C', 'X-Z']

  let zfrom = 0
  let zupto = 0

  function handle_click({ target }) {
    if (!node_names.includes(target.nodeName)) return

    zfrom = +target.dataset.b
    zupto = +target.dataset.e

    const icpos = target.dataset.c || 'X'

    vtform_data.put(ztext, hviet[0], ctree[0], zfrom, zupto, icpos)
    vtform_ctrl.show(0)
  }
</script>

<article class="article island">
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="preview" on:click={handle_click}>
    <div class="left">
      <h3 class="label">Tiếng Trung:</h3>
      <div class="input">
        <textarea
          name="input"
          id=""
          rows="5"
          class="m-input cdata _zh"
          bind:value={ztext} />
      </div>

      <div class="m-flex">
        <label for="" class="x-label">Thuật toán</label>
        <input type="text" name="m_alg" class="m-input" bind:value={m_alg} />
      </div>

      <div class="m-flex">
        <label for="" class="x-label">Từ điển riêng</label>
        <input type="text" name="pdict" class="m-input" bind:value={pdict} />
      </div>

      <button class="m-btn _primary _fill" on:click={call_debug}>
        <span>Parse data!</span>
      </button>

      <h3 class="label">Tiếng Việt:</h3>

      <div class="cdata debug _hv">
        {#each ctree as cdata}
          {@html gen_mt_ai_html(cdata, {
            mode: 2,
            cap: true,
            und: true,
            _qc: 0,
          })}
        {/each}
      </div>

      <h3 class="label">Hán Việt:</h3>

      <div class="cdata debug _hv">
        {#each hviet as hdata}
          {@html gen_hviet_html(hdata, true)}
        {/each}
      </div>
    </div>

    <div class="right">
      <h3 class="label">Cây ngữ pháp:</h3>

      <div class="cdata debug _ct">
        {#each ctree as cdata}
          {@html gen_ctree_html(cdata)}
        {/each}
      </div>
    </div>
  </div>
</article>

{#if $vtform_ctrl.actived} <Vtform {ropts} /> {/if}

<style lang="scss">
  .preview {
    display: flex;
    gap: 0.75rem;
    > * {
      flex: 1;
      height: 100%;
    }
  }

  .m-flex {
    margin: 0.5rem 0;
    label {
      width: 7rem;
    }
    .m-input {
      display: block;
      margin-left: auto;
      flex: 1;
    }
  }

  .label {
    display: flex;
    @include ftsize(md);
    // padding: 0 0.75rem;
    // font-weight: bold;
    line-height: 1rem;

    margin-top: 0.5rem;
    margin-bottom: 0.25rem;
  }

  .cdata {
    padding: 0.25rem 0.5rem;
    @include border();
    @include bdradi;
    @include bgcolor(main);
    @include scroll;

    &._zh {
      $line: 1.5rem;
      line-height: $line;
      @include ftsize(lg);
    }

    &._hv {
      $line: 1.125rem;
      line-height: $line;
    }

    &._ct {
      $line: 1.25rem;
      line-height: $line;
      max-height: $line * 20 + 0.75rem;

      // height: calc(100% - 4rem);

      :global(x-z) {
        font-weight: 500;
      }
    }
  }

  .input {
    // display: flex;
    gap: 0.75rem;

    input,
    textarea {
      width: 100%;
    }
  }
</style>
