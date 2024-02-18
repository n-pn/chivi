<script lang="ts">
  import { browser } from '$app/environment'
  import { debounce } from '$lib/svelte'
  import { mode_names } from '$lib/consts/tl_modes'
  import { Rdpage, Rdword } from '$lib/reader'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Cztext from '$gui/shared/upload/Cztext.svelte'
  import Lookup, { ctrl as lookup_ctrl } from '$gui/parts/Lookup2.svelte'
  import Vtform, { ctrl as vtform_ctrl } from '$gui/shared/vtform/Vtform.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let ztext = data.ztext
  let qkind = data.qkind
  let pdict = data.pdict

  let vtext: string[] = []
  let error: string = ''

  $: if (browser && (ztext || qkind || pdict)) instant_translate()

  $: rpage = new Rdpage(ztext)
  let rword = new Rdword()

  let state = 0
  let tspan = 0
  let l_idx = 0

  const do_translate = async () => {
    state = 1
    l_idx = 0
    vtext = []

    const tspan_start = performance.now()
    let start = 0

    while (start < rpage.lines.length) {
      start = await rpage.load_more(qkind, pdict)
      vtext = rpage.get_texts(qkind)
    }

    tspan = performance.now() - tspan_start
    state = 2
  }

  let output: HTMLDivElement

  const instant_translate = debounce(do_translate, 500)
  const handle_click = async (event: MouseEvent) => {
    let target = event.target as HTMLElement

    while (target != output) {
      if (target.nodeName == 'P') return set_focus_line(target)
      target = target.parentElement
    }
  }

  function move_line_up() {
    if (l_idx < 1) return
    const new_focus = document.getElementById(`L${l_idx - 1}`)
    set_focus_line(new_focus)
  }

  function move_line_down() {
    if (l_idx + 1 >= vtext.length) return
    const new_focus = document.getElementById(`L${l_idx + 1}`)
    set_focus_line(new_focus)
  }

  let focus_line: HTMLElement

  const set_focus_line = async (new_focus: HTMLElement) => {
    if (!new_focus) return
    if (new_focus != focus_line) {
      l_idx = +new_focus.dataset.id

      new_focus.classList.add('focus')
      if (focus_line) focus_line.classList.remove('focus')

      focus_line = new_focus
      focus_line.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
    }

    await rpage.load_hviet(1)
    lookup_ctrl.show('glossary')
  }

  const on_term_change = async (ztext = '') => {
    if (!ztext) return
    await rpage.reload(ztext, qkind, pdict)
    vtext = vtext
  }
</script>

<div class="content">
  <Cztext bind:ztext bind:error limit={2000} />

  <section class="output">
    <header>
      <select class="m-input _xs" name="qkind" id="qkind" bind:value={qkind}>
        {#each Object.entries(mode_names) as [value, label]}
          <option {value}>{label}</option>
        {/each}
      </select>

      <label for="pdict" class="x-label u-right">Từ điển</label>
      <input type="text" class="m-input _xs pdict" bind:value={pdict} />
    </header>
    {#if error}
      <div class="form-msg _err">{error}</div>
    {:else if ztext}
      <!-- svelte-ignore a11y-click-events-have-key-events -->
      <!-- svelte-ignore a11y-no-static-element-interactions -->
      <div class="vhtml" on:click={handle_click} bind:this={output}>
        {#each vtext as line, idx}
          <p id="L{idx}" data-id={idx}>{line}</p>
        {:else}
          <div class="d-empty">
            <SIcon name="loader-2" spin={true} />
            <span>Đang dịch...</span>
          </div>
        {/each}
      </div>
    {:else}
      <p>Nhập văn bản vào phía bên trái</p>
    {/if}

    <footer class="u-fg-tert u-fz-sm">
      {#if state == 1}
        <span class="state u-right">
          <em>Đang dịch...</em>
        </span>
      {:else if state == 2}
        <span class="state u-right">
          <SIcon name="clock" />
          <em>{tspan}ms</em>
        </span>
      {/if}
    </footer>
  </section>
</div>

<div hidden>
  <button type="button" data-kbd="↑" on:click={move_line_up} />
  <button type="button" data-kbd="↓" on:click={move_line_down} />
</div>

{#if ztext && $lookup_ctrl.actived}
  <Lookup
    bind:rpage
    bind:rword
    bind:state
    bind:l_idx
    ropts={{ pdict, rmode: qkind, mt_rm: qkind }}
    l_max={vtext.length} />
{/if}

{#if $vtform_ctrl.actived}
  <Vtform
    rline={rpage.lines[l_idx]}
    ropts={{ pdict, rmode: qkind, mt_rm: qkind }}
    {rword}
    on_close={on_term_change} />
{/if}

<style lang="scss">
  .content {
    display: flex;
    margin-top: 1rem;

    > :global(*) {
      flex: 1 1;
      width: 50%;
    }

    > :global(.ztext) {
      @include bdradi(0, $loc: right);
    }
  }

  .output {
    display: flex;
    flex-direction: column;
    @include border(--bd-main);
    border-left: none;
    @include bdradi($loc: right);
    // padding-left: 0.75rem;
    // padding: 0 0.75rem;
  }

  header {
    @include flex-cy($gap: 0.5rem);
    padding: 0.125rem 0.5rem;
    @include border($loc: bottom);

    // label {
    //   cursor: pointer;
    //   @include flex-cy($gap: 0.25rem);
    // }

    // .m-input {
    //   height: 1.75rem;
    // }
  }

  .vhtml {
    padding: 0.375rem 0.75rem;
    // @include ftsize(lg);
    max-height: 70vh;
    overflow-y: scroll;
    overflow-block: scroll;
    p {
      margin-bottom: 0.25em;
      &:global(.focus),
      &:hover {
        cursor: pointer;
        @include bgcolor(warning, 3, 1);
      }
    }
  }

  .pdict {
    width: 6rem;
    text-align: center;
  }

  footer {
    @include flex-cy($gap: 0.5rem);
    padding: 0.25rem 0.5rem;
    @include border($loc: top);

    margin-top: auto;
  }

  .state {
    @include flex-cy;
  }
</style>
