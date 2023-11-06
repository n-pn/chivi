<script lang="ts" context="module">
  import { writable } from 'svelte/store'
  import { Rdword, type Rdline } from '$lib/reader'
  import { tooltip } from '$lib/actions'
  import { flatten_tree, gen_mt_ai_text } from '$lib/mt_data_2'

  export const ctrl = {
    ...writable({ actived: false, tab: 0 }),
    show: (tab = 0) => {
      ctrl.set({ actived: true, tab })
    },
    hide: () => {
      ctrl.set({ actived: false, tab: 0 })
    },
  }

  const init_tdata = { vstr: '', cpos: '', attr: '', plock: -1, local: true }
</script>

<!-- @hmr:keep-all -->
<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { Viform, find_last } from './viform'

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
  export let ropts: CV.Rdopts
  export let on_close = (changed = false) => console.log(changed)

  let mlist = []
  let tform: Viform = new Viform(rword, init_tdata, '', '', $_user.privi)

  $: {
    mlist = gen_mlist(rline.mt_ai, rword.from, rword.upto)
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

  const cached = new Map<string, any>()

  function make_form(mlist: CV.Cvtree[], { from, upto, cpos }) {
    const key = `${from}-${upto}-${cpos}`

    const old = cached.get(key)
    if (old) return old

    const ztext = rline.get_ztext(from, upto)
    const hviet = rline.get_hviet(from, upto)
    const tdata = { ...init_tdata, cpos, vstr: hviet }

    const vnode = find_last<CV.Cvtree>(mlist, (x) => {
      if (x[2] != from || x[3] != upto) return false
      return x[0] == cpos || cpos == 'X'
    })

    if (vnode) {
      const dnum = vnode[6]
      tdata.cpos = vnode[0]
      tdata.vstr = gen_mt_ai_text(vnode, { cap: false, und: true })
      tdata.attr = vnode[5]
      tdata.plock = Math.floor(dnum / 10)
      tdata.local = dnum % 2 == 1
    }

    const rword = new Rdword(from, upto, tdata.cpos)
    const tform = new Viform(rword, tdata, ztext, hviet, $_user.privi)
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
    const body = tform.toJSON(ropts, rline.ctree_text)

    const init = { body: JSON.stringify(body), method, headers }
    const res = await fetch(action, init)

    if (!res.ok) {
      form_msg = await res.text()
    } else {
      on_close(true)
      ctrl.hide()
    }
  }
</script>

<Dialog actived={$ctrl.actived} on_close={ctrl.hide} class="vtform" _size="lg">
  <FormHead {rline} bind:rword bind:actived={$ctrl.actived} />

  <nav class="tabs">
    <button
      class="htab _edit"
      class:_active={$ctrl.tab == 0}
      data-kbd="⌃`"
      on:click={() => ctrl.show(0)}>
      <span>Thêm sửa từ</span>
    </button>

    <button
      type="button"
      class="htab _novel"
      class:_active={$ctrl.tab == 1}
      data-kbd="⌃1"
      on:click={() => ctrl.show(1)}
      disabled>
      <span>Nghĩa cặp từ</span>
    </button>

    <button
      type="button"
      class="htab _find"
      class:_active={$ctrl.tab == 2}
      data-kbd="⌃2"
      on:click={() => ctrl.show(2)}
      disabled>
      <span>Tách ghép từ</span>
    </button>
  </nav>

  <form class="body" {method} {action} on:submit|preventDefault={submit_action}>
    <div class="tree">
      {#each mlist as [cpos, _body, from, upto], index}
        {@const cpos_data = cpos_info[cpos]}
        {#if index > 0}<span class="sep u-fg-mute">/</span>{/if}
        <button
          type="button"
          class="cbtn"
          class:_active={tform.rword.match(from, upto, cpos)}
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
          <span class="ptag" use:tooltip={cpos_data.desc} data-anchor=".vtform">
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
            <code use:tooltip={attr_info[attr]?.desc} data-anchor=".vtform"
              >{attr}</code>
          {:else}
            <code use:tooltip={'Không có từ tính cụ thể'} data-anchor=".vtform"
              >None</code>
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
      <div class="fmsg">{form_msg}</div>
    {/if}

    <FormBtns
      privi={$_user.privi}
      uname={$_user.uname}
      bind:tform
      bind:show_log
      bind:show_dfn />
  </form>

  <HelpLink key={tform.ztext} />
</Dialog>

{#if pick_cpos}
  <CposPicker bind:output={tform.cpos} bind:actived={pick_cpos} />
{/if}

{#if pick_attr}
  <AttrPicker bind:output={tform.attr} bind:actived={pick_attr} />
{/if}

{#if show_dfn}
  <Glossary bind:actived={show_dfn} {rline} rword={rword.copy()} />
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
</style>