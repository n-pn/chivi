<!-- @hmr:keep-all -->
<script context="module" lang="ts">
  import { onDestroy } from 'svelte'

  import { get_user } from '$lib/stores'
  import { api_call } from '$lib/api_call'
  import { Vtform } from '$lib/models/viterm'

  import { ctrl, data } from '$lib/stores/vtform_stores'
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'
  import cpos_info from '$lib/consts/cpos_info'
  import attr_info from '$lib/consts/attr_info'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  import AttrPicker from '$gui/parts/AttrPicker.svelte'

  import FormHead from './vtform/FormHead.svelte'
  import VstrUtil from './vtform/VstrUtil.svelte'
  import HelpLink from './vtform/HelpLink.svelte'

  export let on_close = () => {}
  onDestroy(on_close)

  const _user = get_user()
  $: privi = $_user.privi

  let { zfrom, zupto, icpos } = $data

  let tform = new Vtform(data.get_term())
  let field: HTMLInputElement

  const refocus = (caret: number = 0) => {
    if (!field) return
    console.log({ caret })
    // field.setSelectionRange(caret, caret)
    field.focus()
  }

  // $: if (tform) refocus()

  $: cpos_data = cpos_info[tform.cpos] || {}
  $: attrs = tform.attr ? tform.attr.split(' ') : []
  // let upsert_error = ''

  // const submit_val = async () => {
  //   const res = await fetch('/_m1/defns', {
  //     method: 'POST',
  //     headers: { 'Content-Type': 'application/json' },
  //     body: form.toJSON($vdict.vd_id, $ztext, $zfrom),
  //   })

  //   const data = await res.json()

  //   if (!res.ok) {
  //     upsert_error = data.message
  //   } else {
  //     $ctrl.state = 0
  //     on_change()
  //   }
  // }

  // const button_colors = [
  //   '_neutral', // base
  //   '_primary', // shared+main
  //   '_harmful', // shared+temp
  //   '_purple', // shared+user
  //   '_success', // initial
  //   '_teal', // unique+main
  //   '_warning', // unique+temp
  //   '_pink', // unique+user
  // ]

  // $: btn_style = button_colors[form.tab + (form.dic < 0 ? 0 : 4)]

  let show_attr_picker = false
</script>

<Dialog actived={$ctrl.actived} on_close={ctrl.hide} class="vtform" _size="lg">
  <FormHead bind:tform bind:zfrom bind:zupto bind:icpos />

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
      <div class="ptag">
        <div class="cpos">
          <span class="plbl u-show-pl">Từ loại:</span>
          <button use:tooltip={cpos_data.desc} data-anchor=".vtform">
            <span>{cpos_data.name || 'Chưa rõ'}</span>
            <strong>({tform.cpos})</strong>
          </button>
        </div>

        <button
          type="button"
          class="attr"
          on:click={() => (show_attr_picker = !show_attr_picker)}>
          <span class="plbl u-show-pm">Từ tính:</span>
          {#each attrs as attr}
            <code use:tooltip={attr_info[attr]?.desc} data-anchor=".vtform"
              >{attr}</code>
          {:else}
            <code use:tooltip={'Không có từ tính cụ thể'} data-anchor=".vtform"
              >None</code>
          {/each}
        </button>
      </div>

      <div class="text" class:_fresh={!tform.init.vstr}>
        <input
          type="text"
          class="vstr"
          bind:this={field}
          bind:value={tform.vstr}
          autocomplete="off"
          autocapitalize="off" />
      </div>
      <VstrUtil bind:tform {field} {refocus} />
    </div>

    <footer class="foot">
      <button
        class="m-btn _lg _fill _primary"
        data-kbd="↵"
        disabled={!tform.changed()}
        on:click={() => console.log(tform)}>
        <SIcon name="send" />
        <span class="submit-text">Lưu</span>
      </button>
    </footer>
  </main>

  <!--



    <upsert-main>
      <DefnHint hanviet={data.hanviet} val_hints={data.val_hints} bind:form />


      <VstrUtil bind:form />
    </upsert-main>

    {#if show_opts}<TermOpts bind:form vdict={$vdict} {privi} />{/if}


      <WsegRank bind:form />



    {#if privi < form.req_privi}
      <div class="upsert-msg _warn">
        Bạn chưa đủ quyền hạn để thêm sửa từ.
        <br />
        Thử bấm vào biểu tượng <SIcon
          name="privi-{form.req_privi}"
          iset="icons" /> phía trên để thay đổi cách lưu.
      </div>
    {:else if upsert_error}
      <div class="upsert-msg _err">{upsert_error}</div>
    {/if}
  </main>
</-->

  <HelpLink key={tform.init.zstr} />
</Dialog>

{#if show_attr_picker}
  <AttrPicker bind:output={tform.attr} bind:actived={show_attr_picker} />
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

  .ptag {
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
    display: flex;

    gap: 0.25rem;
    > button {
      @include ftsize(sm);
      display: inline-flex;
      gap: 0.25rem;
      padding: 0;
      background: inherit;
    }
  }

  .attr {
    margin-left: auto;
    display: flex;
    // align-items: center;

    gap: 0.25rem;
    padding: 0;
    background: inherit;
    line-height: 1.5rem;

    @include ftsize(sm);

    &:hover {
      @include fgcolor(primary);
    }
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

  .text {
    display: flex;
    $h-outer: 3.25rem;
    $h-inner: 1.75rem;

    height: $h-outer;
    padding: math.div($h-outer - $h-inner, 2);

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
  }

  .umsg {
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
