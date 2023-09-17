<!-- @hmr:keep-all -->
<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { Vtform } from '$lib/models/viterm'
  import { ctrl, data } from '$lib/stores/vtform_stores'

  import { onDestroy } from 'svelte'

  import { tooltip } from '$lib/actions'
  import cpos_info from '$lib/consts/cpos_info'
  import attr_info from '$lib/consts/attr_info'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  import CposPicker from '$gui/parts/CposPicker.svelte'
  import AttrPicker from '$gui/parts/AttrPicker.svelte'

  import FormHead from './vtform/FormHead.svelte'
  import TermOpts from './vtform/TermOpts.svelte'
  import VstrUtil from './vtform/VstrUtil.svelte'
  import HelpLink from './vtform/HelpLink.svelte'

  export let pdict: string
  export let on_close = (_term?: CV.Viterm) => {}
  onDestroy(() => on_close(null))

  const cached = new Map<string, Vtform>()

  function make_form(zfrom: number, zupto: number, icpos: string) {
    const key = `${zfrom}-${zupto}-${icpos}`

    const old = cached.get(key)
    if (old) return old

    const term = data.get_term(zfrom, zupto, icpos)
    const form = new Vtform(term, privi)

    cached.set(key, form)
    return form
  }

  $: privi = $_user.privi

  let { zfrom, zupto, icpos } = $data

  $: tform = make_form(zfrom, zupto, icpos)
  $: hviet = tform.init.hviet

  $: if (tform) refocus()
  $: cpos_data = cpos_info[tform.cpos] || {}
  $: attr_list = tform.attr ? tform.attr.split(' ') : []

  let field: HTMLInputElement

  const refocus = (caret: number = 0) => {
    if (!field) return
    if (caret > 0) field.setSelectionRange(caret, caret)
    field.focus()
  }

  let form_msg = ''

  const send_form = async () => {
    const action = '/_ai/terms/once'
    const method = 'PUT'

    const headers = { 'Content-type': 'application/json' }
    const body = tform.to_form_body(pdict, $data.vtree, zfrom)

    const init = { body: JSON.stringify(body), method, headers }
    const res = await fetch(action, init)

    if (!res.ok) {
      form_msg = await res.text()
    } else {
      const term = await res.json()
      on_close(term as CV.Viterm)
      ctrl.hide()
    }
  }

  const button_styles = [
    '_default', // primary + plock 0
    '_warning', // primary + plock 1
    '_harmful', // primary + plock 2
    '_success', // regular + plock 1
    '_primary', // regular + plock 1
    '_teal', // regular + plock 2
  ]

  $: btn_style = button_styles[tform.local ? tform.plock : tform.plock + 3]

  let pick_cpos = false
  let pick_attr = false
</script>

<Dialog actived={$ctrl.actived} on_close={ctrl.hide} class="vtform" _size="lg">
  <FormHead bind:zfrom bind:zupto bind:icpos {hviet} />

  <nav class="tabs">
    <button
      class="htab _edit"
      class:_active={$ctrl.tab == 0}
      data-kbd="x"
      on:click={() => ctrl.show(0)}>
      <SIcon name="package" />
      <span>Thêm sửa từ</span>
    </button>

    <button
      type="button"
      class="htab _find"
      class:_active={$ctrl.tab == 1}
      data-kbd="c"
      on:click={() => ctrl.show(1)}
      disabled>
      <SIcon name="compass" />
      <span>Tra nghĩa</span>
    </button>

    <button
      type="button"
      class="htab _novel"
      class:_active={$ctrl.tab == 2}
      data-kbd="v"
      on:click={() => ctrl.show(2)}
      disabled>
      <SIcon name="tools" />
      <span>Nâng cao</span>
    </button>
  </nav>

  <main class="body">
    <div class="main">
      <div class="main-head">
        <button class="cpos" on:click={() => (pick_cpos = !pick_cpos)}>
          <span class="plbl u-show-pl">Từ loại:</span>
          <span class="ptag" use:tooltip={cpos_data.desc} data-anchor=".vtform">
            <code>{tform.cpos}</code>
            <span class="name">{cpos_data.name || 'Chưa rõ'}</span>
            <SIcon name={tform.cpos == '_' ? 'lock-open' : 'lock'} />
          </span>
        </button>

        <button
          type="button"
          class="attr"
          on:click={() => (pick_attr = !pick_attr)}>
          <span class="plbl u-show-pm">Từ tính:</span>
          {#each attr_list as attr}
            <code use:tooltip={attr_info[attr]?.desc} data-anchor=".vtform"
              >{attr}</code>
          {:else}
            <code use:tooltip={'Không có từ tính cụ thể'} data-anchor=".vtform"
              >None</code>
          {/each}
        </button>
      </div>

      <div class="main-text" class:_fresh={!tform.init.vstr}>
        <input
          type="text"
          class="vstr"
          bind:this={field}
          bind:value={tform.vstr}
          autocomplete="off"
          autocapitalize="off" />

        <TermOpts bind:tform {privi} />
      </div>

      <VstrUtil bind:tform {field} {refocus} />
    </div>

    {#if form_msg}
      <div class="fmsg">{form_msg}</div>
    {/if}

    <footer class="foot">
      <button
        class="m-btn _lg _fill {btn_style} _send"
        data-kbd="↵"
        disabled={privi < tform.req_privi}
        on:click={send_form}>
        <SIcon name="send" />
        <span class="submit-text">Lưu</span>
        <SIcon name="privi-{tform.req_privi}" iset="icons" />
      </button>
    </footer>
  </main>

  <HelpLink key={tform.init.zstr} />
</Dialog>

{#if pick_cpos}
  <CposPicker bind:output={tform.cpos} bind:actived={pick_cpos} />
{/if}

{#if pick_attr}
  <AttrPicker bind:output={tform.attr} bind:actived={pick_attr} />
{/if}

<style lang="scss">
  $gutter: 0.75rem;

  $tab-height: 2rem;

  .tabs {
    margin-top: 0.5rem;
    height: $tab-height;
    padding: 0 0.75rem;

    gap: 0.5rem;
    @include flex;
    @include border(--bd-main, $loc: bottom);

    justify-content: center;
    font-size: rem(14px);

    // prettier-ignore
  }

  .htab {
    cursor: pointer;
    @include flex($center: vert);
    // text-transform: capitalize;
    padding: 0 0.375rem;
    flex-shrink: 0;
    height: $tab-height;
    line-height: $tab-height;
    font-weight: 500;
    background-color: transparent;

    @include bdradi($loc: top);
    @include fgcolor(tert);
    @include border(--bd-main, $loc: top-left-right);

    &:hover {
      @include bgcolor(secd);
    }

    &._active {
      flex-shrink: 0;
      @include bgcolor(secd);
      @include fgcolor(primary, 5);
      @include bdcolor(primary, 5);
    }

    > span {
      display: block;
      @include clamp($width: 100%, $style: '-');
    }

    > :global(svg) {
      width: 1.25rem;
      margin-right: 0.125rem;
      @include bps(display, none, $pl: inline-block);
    }
  }

  // .tab-btn {
  //   padding: 0 0.5rem;
  //   background-color: transparent;

  //   height: $tab-height;
  //   line-height: $tab-height;
  //   @include fgcolor(tert);
  //   &:hover {
  //     @include fgcolor(primary, 5);
  //   }
  // }

  .body {
    display: block;
    padding: 0.75rem;
    padding-top: 2rem;

    @include bgcolor(bg-secd);
  }

  .main {
    display: block;
    @include bdradi;

    @include linesd(--bd-main, $inset: true);
    @include bgcolor(main);

    &:focus-within {
      // @include linesd(primary, 4, $ndef: false);
      @include bgcolor(secd);
    }
  }

  .main-head {
    @include flex();

    justify-content: space-between;
    padding: 0.25rem 0.5rem;
    height: 2rem;

    code {
      padding: 0 0.375rem;
      @include bgcolor(neutral, 4, 1);
    }
  }

  .plbl {
    font-size: rem(10px);
    text-transform: uppercase;
    margin-top: 0.05rem;
  }

  .cpos {
    display: inline-flex;
    gap: 0.25rem;

    padding: 0;
    background: inherit;
    @include fgcolor(tert);
  }

  .ptag {
    @include ftsize(sm);
    display: inline-flex;
    align-items: center;
  }

  .attr {
    display: inline-flex;
    gap: 0.25rem;
    // align-items: center;
    margin-left: auto;
    padding: 0;
    background: inherit;
    line-height: 1.5rem;

    @include ftsize(sm);
    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary);
    }
  }

  .main-text {
    display: flex;
    $h-outer: 3.25rem;
    $h-inner: 2rem;

    height: $h-outer;
    padding: math.div($h-outer - $h-inner, 2) 0.625rem;

    @include linesd(--bd-soft, $inset: true);

    &:focus-within {
      @include linesd(primary, 4, $ndef: false);
    }

    > * {
      height: $h-inner;
      // line-height: 1.75rem;
    }

    &._fresh > * {
      font-style: italic;
    }
  }

  .vstr {
    flex: 1;
    min-width: 1rem;
    outline: 0;
    border: 0;
    background: transparent;
    @include fgcolor(main);
    @include ftsize(lg);
  }

  .foot {
    @include flex-ca;
    gap: 0.75rem;
    padding-top: 0.75rem;

    ._send {
      margin-left: auto;
    }
  }

  .fmsg {
    margin-top: -0.25rem;
    font-size: rem(13px);
    line-height: 1rem;
    padding-bottom: 0.5rem;
    text-align: center;
    font-style: italic;

    &._warn {
      @include fgcolor(warning);
    }

    &._err {
      @include fgcolor(harmful);
    }
  }

  .empty {
    height: 15rem;
    @include flex-ca;
  }
</style>
