<script lang="ts" context="module">
  import { writable } from 'svelte/store'
  import { Rdword, type Rdline } from '$lib/reader'
  import { tooltip } from '$lib/actions'

  export const ctrl = {
    ...writable({ actived: false, tab: 0 }),
    show: (tab = 0) => {
      ctrl.set({ actived: true, tab })
    },
    hide: () => {
      ctrl.set({ actived: false, tab: 0 })
    },
  }
</script>

<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { Viform } from './zvdefn_form'

  import cpos_info from '$lib/consts/cpos_info'
  import attr_info from '$lib/consts/attr_info'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  import CposPicker from '$gui/parts/CposPicker.svelte'
  import AttrPicker from '$gui/parts/AttrPicker.svelte'

  import Glossary from './Glossary.svelte'
  import FormHead from './FormHead.svelte'
  import VstrUtil from './VstrUtil.svelte'
  import FormBtns from './FormBtns.svelte'
  import HelpLink from './HelpLink.svelte'

  export let rline: Rdline
  export let rword: Rdword
  export let ropts: Partial<CV.Rdopts>
  export let on_close = (zstr = '') => console.log(zstr)

  let tform: Viform = new Viform([], rword, '')

  $: mlist = rline.trans[ropts.mt_rm] as CV.Mtnode[]
  $: mtree = filter_mtree(mlist, rword.from, rword.upto)

  $: tform = make_form(mlist, rword)

  $: if (tform) refocus()
  $: cpos_data = cpos_info[tform.cpos] || {}
  $: attr_list = tform.attr ? tform.attr.split(' ') : []

  let pick_cpos = false
  let pick_attr = false

  let show_log = false
  let show_dfn = false

  const filter_mtree = (input: CV.Mtnode[], from: number, upto: number) => {
    let mtree = []

    for (const node of input) {
      if (node[1] <= from && node[2] >= upto) mtree.push(node)
    }

    if (mtree.length > 3) mtree = mtree.slice(mtree.length - 3)

    for (const node of input) {
      if (node[1] >= from && node[2] < upto) mtree.push(node)
    }

    return mtree.slice(0, 5)
  }

  const cached = new Map<string, Viform>()

  function make_form(mlist: CV.Mtnode[], { from, upto, cpos }) {
    const key = `${from}-${upto}-${cpos}`

    const existed = cached.get(key)
    if (existed) return existed

    const ztext = rline.get_ztext(from, upto)
    const hviet = rline.get_hviet(from, upto)

    const tform = new Viform(mlist, rword, ztext, hviet, $_user.privi)

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

  const action = '/_ai/zvdefns/once'
  const method = 'PUT'
  const headers = { 'Content-type': 'application/json' }

  const submit_action = async () => {
    const body = JSON.stringify({
      zstr: tform.zstr,
      ...tform.fdata,
      pdict: ropts.pdict,
      m_alg: ropts.mt_rm,
      // m_con: rline.ctree_text(ropts.mt_rm),
      zfrom: rword.from,
    })

    if (tform.cpos == 'NR') add_wseg(tform.zstr, tform.zstr)

    const res = await fetch(action, { body: body, method, headers })

    if (!res.ok) {
      form_msg = await res.text()
    } else {
      on_close(tform.zstr)
      ctrl.hide()
    }
  }

  async function add_wseg(zstr: string, wseg: string) {
    const body = JSON.stringify({ zstr, wseg, pdict: ropts.pdict, srank: 1 })
    const resp = await fetch('/_sp/wseg', { body, headers, method })
    if (!resp.ok) console.log(await resp.text())
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
      {#each mtree as [_, from, upto, cpos], index}
        {@const cpos_data = cpos_info[cpos] || { name: cpos }}
        {#if index > 0}<span class="sep u-fg-mute">/</span>{/if}
        <button
          type="button"
          class="cbtn"
          class:_active={rword.match(from, upto, cpos)}
          data-tip="Chọn [{cpos_data.name}] từ ký tự thứ {from + 1} tới {upto}"
          on:click={() => (rword = new Rdword(from, upto, cpos))}>
          <code>{cpos}</code>
          <!-- <span class="u-fg-mute">{upto - from}</span> -->
          <span>{from + 1}&ndash;{upto}</span>
        </button>
      {/each}
    </div>

    <div class="main">
      <div class="main-head">
        <button type="button" class="cpos" data-kbd="u" on:click={() => (pick_cpos = !pick_cpos)}>
          <span class="plbl u-show-pl">Từ loại:</span>
          <span class="ptag" use:tooltip={cpos_data.desc} data-anchor=".vtform">
            <code>{tform.cpos}</code>
            <span class="name">{cpos_data.name || 'Chưa rõ'}</span>
          </span>
        </button>

        <button type="button" class="attr" data-kbd="i" on:click={() => (pick_attr = !pick_attr)}>
          <span class="plbl u-show-pl">Từ tính:</span>
          {#each attr_list as attr}
            <code use:tooltip={attr_info[attr]?.desc} data-anchor=".vtform">{attr}</code>
          {:else}
            <code use:tooltip={'Không có từ tính cụ thể'} data-anchor=".vtform">None</code>
          {/each}
        </button>

        <button
          type="button"
          class="rank"
          class:_active={tform.fixed_cpos()}
          data-kbd="f"
          use:tooltip={'Áp dụng từ loại/nghĩa duy nhất cho cụm từ'}
          data-anchor=".vtform"
          on:click={() => (tform.fdata.rank = tform.fixed_cpos() ? 1 : 3)}>
          <SIcon name={tform.fixed_cpos() ? 'checkbox' : 'square'} />
          <span class="ptag">Đơn nghĩa</span>
        </button>
      </div>

      <div class="main-text">
        <input
          type="text"
          class="vstr"
          bind:this={field}
          bind:value={tform.vstr}
          autocomplete="off"
          autocapitalize="off" />
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

    <FormBtns privi={$_user.privi} uname={$_user.uname} bind:tform bind:show_dfn />
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

    gap: 0.5rem;
    padding: 0.25rem 0.625rem;
    height: 2rem;

    code {
      padding: 0 0.375rem;
      @include bgcolor(neutral, 4, 1);
    }

    > * {
      display: inline-flex;
      gap: 0.25rem;
      align-items: center;
      padding: 0;
      background: inherit;
      line-height: 1.5rem;
    }
  }

  .plbl {
    font-size: rem(10px);
    text-transform: uppercase;
    margin-top: 0.05rem;
  }

  .cpos {
    @include fgcolor(tert);
  }

  .ptag {
    @include ftsize(sm);
  }

  .attr {
    @include ftsize(sm);
    @include fgcolor(tert);

    &:hover {
      @include fgcolor(primary);
    }
  }

  .rank {
    margin-left: auto;

    text-transform: none;
    // @include ftsize(sm);
    @include fgcolor(tert);

    &:hover,
    &._active {
      @include fgcolor(warning);
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
