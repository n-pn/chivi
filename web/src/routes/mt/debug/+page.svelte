<script lang="ts">
  import { Rdline, Rdpage, Rdword } from '$lib/reader'

  import Vtform, { ctrl as vtform_ctrl } from '$gui/shared/vtform/Vtform.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let ztext = data.ztext || ''
  let ropts: CV.Rdopts = {
    fpath: '',
    pdict: data.pdict || 'combine',
    rmode: 'mt',
    mt_rm: data.m_alg || 'mtl_2',
    qt_rm: 'bd_zv',
    wn_id: 0,
  }

  $: rpage = new Rdpage(ztext)

  const call_debug = async () => {
    await rpage.load_hviet(2)
    await rpage.load_more(ropts.mt_rm, ropts.pdict)
    vtform_ctrl.show(0)
  }

  const node_names = ['X-N', 'X-C', 'X-Z']

  let rword = new Rdword()

  const handle_click = ({ target }) => {
    if (!node_names.includes(target.nodeName)) return
    rword = Rdword.from(target)
    vtform_ctrl.show(0)
  }

  const on_vtform_close = async (zstr = '') => {
    const l_ids = await rpage.reload(zstr, ropts.mt_rm, ropts.pdict)
    console.log({ l_ids })
    rpage = rpage
  }
</script>

<article class="article island">
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="preview" on:click={handle_click}>
    <div class="left">
      <h3 class="label">Tiếng Trung:</h3>
      <div class="input">
        <textarea name="input" id="" rows="5" class="m-input cdata _zh" bind:value={ztext} />
      </div>

      <div class="m-flex">
        <label for="" class="x-label">Thuật toán</label>
        <input type="text" name="m_alg" class="m-input" bind:value={ropts.mt_rm} />
      </div>

      <div class="m-flex">
        <label for="" class="x-label">Từ điển riêng</label>
        <input type="text" name="pdict" class="m-input" bind:value={ropts.pdict} />
      </div>

      <button class="m-btn _primary _fill" on:click={call_debug}>
        <span>Parse data!</span>
      </button>

      <h3 class="label">Tiếng Việt:</h3>

      <h3 class="label">Tiếng Việt:</h3>

      <div class="cdata debug _hv">
        {#each rpage.lines || [] as rline}
          {@html rline.mtran_html(ropts.mt_rm)}
        {/each}
      </div>

      <h3 class="label">Hán Việt:</h3>

      <div class="cdata debug _hv">
        {#each rpage.lines || [] as rline}
          {@html rline.hviet_html}
        {/each}
      </div>
    </div>

    <div class="right">
      <h3 class="label">Cây ngữ pháp:</h3>

      <div class="cdata debug _ct">
        {#each rpage.lines as rline}
          TODO!
        {/each}
      </div>
    </div>
  </div>
</article>

{#if $vtform_ctrl.actived}
  <Vtform rline={rpage.lines[0]} {rword} {ropts} on_close={on_vtform_close} />
{/if}

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

    textarea {
      width: 100%;
    }
  }
</style>
