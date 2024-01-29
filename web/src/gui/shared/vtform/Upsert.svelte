<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { Viform } from './viform'

  import cpos_info from '$lib/consts/cpos_info'
  import attr_info from '$lib/consts/attr_info'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  import CposPicker from '$gui/parts/CposPicker.svelte'
  import AttrPicker from '$gui/parts/AttrPicker.svelte'

  import Glossary from './Glossary.svelte'
  import FormHead from './FormHead.svelte'
  import VstrBtns from './VstrBtns.svelte'
  import VstrUtil from './VstrUtil.svelte'
  import FormBtns from './FormBtns.svelte'
  import HelpLink from './HelpLink.svelte'

  export let rline: Rdline
  export let rword: Rdword
  export let ropts: Partial<CV.Rdopts>
  export let on_close = (changed = false) => console.log(changed)

  let mlist = []
  let tform: Viform = new Viform(rline, rword, mlist)

  $: {
    mlist = gen_mlist(rline.mtran[ropts.mt_rm], rword.from, rword.upto)
    tform = make_form(mlist, rword)
  }

  $: if (tform) refocus()
  $: cpos_data = cpos_info[tform.cpos] || {}
  $: attr_list = tform.attr ? tform.attr.split(' ') : []

  let pick_cpos = false
  let pick_attr = false

  let show_log = false
  let show_dfn = false

  const gen_mlist = (ctree: CV.Cvtree, from: number, upto: number) => {
    if (!ctree) return []
    const input = flatten_tree(ctree)

    let mlist = []

    for (const node of input) {
      if (node[2] <= from && node[3] >= upto) mlist.push(node)
    }

    if (mlist.length > 4) mlist = mlist.slice(mlist.length - 4)

    for (const node of input) {
      if (node[2] >= from && node[3] < upto) mlist.push(node)
    }

    return mlist.slice(0, 6)
  }

  const cached = new Map<string, Viform>()

  function make_form(mlist: CV.Cvtree[], { from, upto, cpos }) {
    const key = `${from}-${upto}-${cpos}`

    const existed = cached.get(key)
    if (existed) return existed

    const tform = new Viform(rline, rword, mlist)
    cached.set(key, tform)
    return tform
  }

  let field: HTMLInputElement

  const refocus = (caret: number = 0) => {
    if (!field) return
    if (caret > 0) field.setSelectionRange(caret, caret)
    field.focus()
  }

  let form_msg = ''

  const action = '/_ai/terms/once'
  const method = 'PUT'

  const submit_action = async () => {
    const headers = { 'Content-type': 'application/json' }

    const _ctx = { ...ropts, ctree: rline.ctree_text(ropts.mt_rm) }
    const body = tform.toJSON(_ctx)

    const init = { body: JSON.stringify(body), method, headers }
    const res = await fetch(action, init)

    if (!res.ok) {
      form_msg = await res.text()
    } else {
      on_close(true)
    }
  }
</script>

<form class="body" {method} {action} on:submit|preventDefault={submit_action}>
  <div class="tree">
    {#each mlist as [cpos, _body, from, upto], index}
      {@const cpos_data = cpos_info[cpos]}
      {#if index > 0}<span class="sep u-fg-mute">/</span>{/if}
      <button
        type="button"
        class="cbtn"
        class:_active={rword.match(from, upto, cpos)}
        data-tip="Chọn [{cpos_data.name}] từ ký tự thứ {from + 1} tới {upto +
          1}"
        on:click={() => (rword = new Rdword(from, upto, cpos))}>
        <code>{cpos}</code>
        <!-- <span class="u-fg-mute">{upto - from}</span> -->
        <span>{from + 1}&ndash;{upto + 1}</span>
      </button>
    {/each}
  </div>

  <div class="main">
    <div class="main-head">
      <button
        type="button"
        class="cpos"
        data-kbd="u"
        on:click={() => (pick_cpos = !pick_cpos)}>
        <span class="plbl u-show-pl">Từ loại:</span>
        <span class="ptag" data-tip="cpos_data.desc}">
          <code>{tform.cpos}</code>
          <span class="name">{cpos_data.name || 'Chưa rõ'}</span>
          <SIcon name={tform.cpos == 'X' ? 'lock-open' : 'lock'} />
        </span>
      </button>

      <button
        type="button"
        class="attr"
        data-kbd="i"
        on:click={() => (pick_attr = !pick_attr)}>
        <span class="plbl u-show-pm">Từ tính:</span>
        {#each attr_list as attr}
          <code data-tip={attr_info[attr]?.desc}>{attr}</code>
        {:else}
          <code data-tip="Không có từ tính cụ thể">None</code>
        {/each}
      </button>
    </div>

    <div class="main-text" class:_fresh={!tform.tinit.vstr}>
      <input
        type="text"
        class="vstr"
        bind:this={field}
        bind:value={tform.vstr}
        autocomplete="off"
        autocapitalize="off" />

      <VstrBtns bind:tform />
    </div>

    <VstrUtil bind:tform {field} />
  </div>

  {#if form_msg}
    <div class="form-msg _err">
      Lỗi: {form_msg}
    </div>
  {:else if tform.req_privi > $_user.privi}
    <div class="form-msg u-warn">
      Gợi ý: Bạn cần thiết quyền hạn {tform.req_privi} để thêm/sửa từ.
    </div>
  {/if}

  <FormBtns
    privi={$_user.privi}
    uname={$_user.uname}
    bind:tform
    bind:show_dfn />
</form>

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
    padding: 0 0.5rem;
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
    padding-top: 0;

    @include bgcolor(secd);
  }

  .tree {
    @include flex-ca($gap: 0.25rem);
    padding: 0.25rem 0;

    .sep {
      @include fgcolor(mute);
    }
  }

  .cbtn {
    display: inline-flex;
    gap: 0.125rem;
    padding: 0;
    line-height: 1.5rem;
    background: transparent;

    &:hover,
    &._active {
      > code {
        @include fgcolor(main);
      }

      > span {
        @include fgcolor(secd);
      }
    }

    > span {
      @include ftsize(sm);
      @include fgcolor(mute);
    }

    > code {
      padding: 0;
      @include fgcolor(tert);
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

  .main-head {
    @include flex();

    justify-content: space-between;
    padding: 0.25rem 0.625rem;
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
    gap: 0.2em;
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

    height: $h-outer;

    @include linesd(--bd-soft, $inset: true);

    &:focus-within {
      @include linesd(primary, 4, $ndef: false);
    }

    &._fresh > * {
      font-style: italic;
    }

    input {
      $h-inner: 2rem;
      padding: math.div($h-outer - $h-inner, 2) 0.625rem;
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

  .form-msg {
    text-align: center;
    margin-top: 0.375rem;
    line-height: 1rem;
    & + :global(*) {
      margin-top: -0.375rem;
    }
  }
</style>
