<!-- @hmr:keep-all -->
<script context="module" lang="ts">
  import { onDestroy } from 'svelte'

  import { get_user } from '$lib/stores'
  import { api_call } from '$lib/api_call'

  import { ctrl, data } from '$lib/stores/vtform_stores'
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  import FormHead from './vtform/FormHead.svelte'
  import PrevDefn from './vtform/PrevDefn.svelte'

  import DefnHint from './vtform/DefnHint.svelte'
  import DefnUtil from './vtform/DefnUtil.svelte'

  import TermOpts from './vtform/TermOpts.svelte'
  import WsegRank from './vtform/WsegRank.svelte'

  import HelpUrls from './vtform/HelpUrls.svelte'

  export let on_close = () => {}

  onDestroy(on_close)

  const _user = get_user()
  $: privi = $_user.privi

  let show_opts = false

  // let zstr = $data.ztext.substring($zfrom, $zupto)
  // let form = CvtermForm.from(key, $vdict.vd_id, privi)

  // $: dicts = upsert_dicts($vdict)
  // $: update_data($ztext, $zfrom, $zupto)

  // let cached: Record<string, JsonData> = {}

  // async function update_data(ztext: string, zfrom: number, zupto: number) {
  //   const vd_id = $vdict.vd_id
  //   const words = related_words(ztext, zfrom, zupto)

  //   const body = words.filter((w) => !cached[w]).slice(0, 5)

  //   if (body.length > 0) {
  //     const api = `/_m1/terms/query?vd_id=${vd_id}`
  //     const res: Record<string, JsonData> = await api_call(api, body, 'POST')
  //     for (let key in res) cached[key] = res[key]
  //   }

  //   data = cached[words[0]]
  //   form = new CvtermForm(data.current, vd_id, privi)
  // }

  // let field: HTMLInputElement
  // const refocus = () => field && field.focus()

  // $: if (form) refocus()

  // const copy_raw = () => navigator.clipboard.writeText(key)

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
</script>

<Dialog actived={$ctrl.actived} on_close={ctrl.hide} class="upsert" _size="lg">
  <FormHead />
  <!--
  <upsert-tabs>
    <button
      class="tab-item _miscs"
      class:_active={$ctrl.tab == 0}
      data-kbd="x"
      on:click={() => ctrl.set_tab(0)}>
      <SIcon name="package" />
      <span>Thêm sửa từ</span>
    </button>

    <button
      class="tab-item _basic"
      class:_active={$ctrl.tab == 1}
      data-kbd="c"
      on:click={() => ctrl.set_tab(1)}>
      <SIcon name="history" />
      <span>Lịch sử thêm sửa</span>
    </button>

    <button
      class="tab-item _novel"
      class:_active={$ctrl.tab == 2}
      data-kbd="c"
      on:click={() => ctrl.set_tab(2)}>
      <SIcon name="message" />
      <span>Tranh luận</span>
    </button>
  </upsert-tabs>
</-->
  <main class="upsert-body">
    <PrevDefn {form} {dicts} />

    <upsert-main>
      <DefnHint hanviet={data.hanviet} val_hints={data.val_hints} bind:form />
      <div class="value" class:_fresh={form.init.id == 0}>
        <input
          type="text"
          class="-input"
          bind:this={field}
          bind:value={form.val}
          autocomplete="off"
          autocapitalize="off" />

        <button class="ptag" data-kbd="w" on:click={() => ctrl.set_state(2)}>
          {pt_labels[form.ptag] || 'Phân loại'}
        </button>
      </div>

      <DefnUtil bind:form />
    </upsert-main>

    {#if show_opts}<TermOpts bind:form vdict={$vdict} {privi} />{/if}

    <upsert-foot>
      <WsegRank bind:form />

      <btn-group>
        <button
          class="m-btn _lg _fill {btn_style}"
          class:_active={show_opts}
          data-kbd="&bsol;"
          data-key="Backslash"
          use:hint={'Thay đổi lựa chọn lưu trữ'}
          on:click={() => (show_opts = !show_opts)}>
          <SIcon name="privi-{form.req_privi}" iset="extra" />
        </button>

        <button
          class="m-btn _lg _fill {btn_style}"
          data-kbd="↵"
          disabled={!form.changed()}
          on:click={submit_val}>
          <span class="submit-text">Lưu</span>
        </button>
      </btn-group>
    </upsert-foot>

    {#if privi < form.req_privi}
      <div class="upsert-msg _warn">
        Bạn chưa đủ quyền hạn để thêm sửa từ.
        <br />
        Thử bấm vào biểu tượng <SIcon
          name="privi-{form.req_privi}"
          iset="extra" /> phía trên để thay đổi cách lưu.
      </div>
    {:else if upsert_error}
      <div class="upsert-msg _err">{upsert_error}</div>
    {/if}
  </main>

  <HelpUrls key={data.get_zstr()} />
</Dialog>

<style lang="scss">
  $gutter: 0.75rem;

  header {
    @include flex();

    @include border(--bd-soft, $loc: bottom);

    .m-btn {
      @include fgcolor(neutral, 5);
      background: none;
      --linesd: none;

      &:hover {
        @include fgcolor(primary, 5);
      }
    }
  }

  $tab-height: 2rem;

  upsert-tabs {
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

  .tab-item {
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

    &._edited {
      @include fgcolor(secd);
    }

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

  .tab-btn {
    padding: 0 0.5rem;
    background-color: transparent;

    height: $tab-height;
    line-height: $tab-height;
    @include fgcolor(tert);
    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  .upsert-body {
    display: block;
    padding: 0 0.75rem;
    @include bgcolor(bg-secd);
  }

  upsert-main {
    display: block;
    @include bdradi;

    @include linesd(--bd-main, $inset: true);
    @include bgcolor(main);

    &:focus-within {
      // @include linesd(primary, 4, $ndef: false);
      @include bgcolor(secd);
    }
  }

  .value {
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

    > .-input {
      flex: 1;
      min-width: 1rem;
      outline: 0;
      border: 0;
      background: transparent;
      @include fgcolor(main);
      @include ftsize(lg);
    }
  }

  .ptag {
    white-space: nowrap;
    padding: 0 0.5rem;
    margin-left: 0.5rem;
    background: transparent;
    border-radius: 0.75rem;
    font-weight: 500;

    @include fgcolor(tert);
    @include linesd(--bd-main);
    @include bps(font-size, rem(12px), rem(13px), rem(14px));

    &:hover {
      @include fgcolor(primary, 5);
    }
  }

  upsert-foot {
    display: flex;
    padding: 0.75rem 0;
  }

  .upsert-msg {
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

  btn-group {
    @include flex();

    > button:first-child {
      border-top-right-radius: 0;
      border-bottom-right-radius: 0;
    }

    > button:last-child {
      border-top-left-radius: 0;
      border-bottom-left-radius: 0;
      margin-left: -1px;
    }
  }

  .empty {
    height: 15rem;
    @include flex-ca;
  }
</style>
