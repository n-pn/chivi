<script context="module" lang="ts">
  import { ptnames } from '$gui/parts/Postag.svelte'
  const v_kbd = ['q', '@', '#', '$', '%', '^']
  const p_kbd = ['-', '=']

  function similar_tags(ptag: string) {
    switch (ptag) {
      case '_':
        return ['n', 'a', 'v']

      case 'ng':
      case 'nl':
      case 'np':
        return ['n']

      case 'nz':
        return ['nr', 'nn']

      case 'nn':
        return ['nr', 'nz']

      case 'n':
        return ['na', 't']

      case 'na':
        return ['n', 'an']

      case 'a':
        return ['b', 'an']

      case 'b':
        return ['a', 'n']

      case 'an':
        return ['a', 'na']

      case 'ad':
        return ['a', 'd']

      case 'ag':
        return ['a', 'k']

      case 'v':
        return ['vi', 'vn']

      case 'vd':
        return ['v', 'd']

      case 'vn':
        return ['v', 'n']

      case 'vi':
        return ['v', 'vo']

      case 'vg':
        return ['v', 'kv']

      case 'r':
      case 'rr':
      case 'ry':
      case 'rz':
        return ['rr', 'rz', 'ry']

      case 'al':
        return ['a', 'b']

      case 'vl':
        return ['al', 'nl']

      case 'i':
        return ['nl', 'al']

      case 'm':
      case 'q':
      case 'mp':
        return ['m', 'q', 'mq']

      case 'c':
      case 'cc':
      case 'd':
        return ['d', 'c', 'cc']

      case 'e':
      case 'y':
      case 'o':
        return ['e', 'y', 'o']

      case 'k':
      case 'ka':
      case 'kn':
      case 'kv':
        return ['ka', 'kn', 'kv']

      default:
        return ['n', 'v', 'a']
    }
  }
</script>

<script lang="ts">
  import { hint } from './_shared'

  import { SIcon } from '$gui'
  import type { VpTerm } from '$lib/vp_term'

  export let vpterm: VpTerm
  export let dname = 'combine'

  $: val_hints = gen_val_hints(vpterm.init.h_vals || [], vpterm.val.trim())

  function gen_val_hints(hints: Array<string>, cval: string) {
    return hints.filter((x, i) => i == 0 || x != cval)
  }

  $: tag_hints = gent_tag_hints(dname, vpterm)

  function gent_tag_hints(dname: string, vpterm: VpTerm): string[] {
    if (dname == 'hanviet' || dname == 'tradsim') return []
    return vpterm.h_ptags(similar_tags(vpterm.ptag))
  }

  // show_mode = 0 => show minimal
  // show_mode = 1 => show vals, hide tags
  // show_mode = 2 => show tags, hide vals
  var show_mode = 0
</script>

<div hidden={true}>
  <button data-kbd="~" on:click={() => (vpterm.val = vpterm.o_val)} />
  <button data-kbd="[" on:click={() => (vpterm.ptag = 'nr')} />
  <button data-kbd="]" on:click={() => (vpterm.ptag = 'nn')} />
  <button data-kbd="." on:click={() => (vpterm.ptag = 'nz')} />
  <button data-kbd="/" on:click={() => (vpterm.ptag = 'nw')} />
  <button data-kbd=";" on:click={() => (vpterm.ptag = 'al')} />
  <button data-kbd="'" on:click={() => (vpterm.ptag = 'vl')} />
  <button data-kbd="n" on:click={() => (vpterm.ptag = 'n')} />
</div>

<div class="hints">
  {#each val_hints as val, idx (val)}
    {@const _hide = show_mode == 0 ? idx > 2 : show_mode == 2 ? idx > 0 : false}
    <button
      class="hint"
      class:_base={val == vpterm.init.b_val}
      class:_priv={val == vpterm.init.u_val}
      class:_hide
      data-kbd={v_kbd[idx]}
      on:click={() => (vpterm.val = val)}>{val}</button>
  {/each}

  {#if val_hints.length > 2 || show_mode == 2}
    <button
      class="hint _icon"
      on:click={() => (show_mode = show_mode == 1 ? 0 : 1)}
      use:hint={'Ẩn/hiện các gợi ý nghĩa cụm từ'}
      ><SIcon name="chevron-{show_mode == 1 ? 'left' : 'right'}" /></button>
  {/if}

  <div class="right">
    {#each tag_hints as tag, idx (tag)}
      {@const _hide =
        show_mode == 0 ? idx > 1 : show_mode == 1 ? idx > 0 : false}
      <button
        class="hint _ptag"
        class:_base={tag == vpterm.init.b_ptag}
        class:_priv={tag == vpterm.init.u_ptag}
        class:_hide
        data-kbd={p_kbd[idx]}
        on:click={() => (vpterm.ptag = tag)}>{ptnames[tag] || tag}</button>
    {/each}

    {#if tag_hints.length > 2 || show_mode == 1}
      <button
        class="hint _icon"
        on:click={() => (show_mode = show_mode == 2 ? 0 : 2)}
        use:hint={'Ẩn/hiện các gợi ý thể loại'}
        ><SIcon name="chevron-{show_mode == 2 ? 'left' : 'right'}" /></button>
    {/if}
  </div>
</div>

<style lang="scss">
  .hints {
    padding: 0 0.5rem;
    height: 2rem;

    @include flex();
    @include ftsize(sm);
  }

  .right {
    margin-left: auto;
    @include flex();
  }

  // prettier-ignore
  .hint {
    // display: inline-flex;
    // align-items: center;
    cursor: pointer;
    padding: 0.25rem;
    line-height: 1.5rem;
    background-color: inherit;
    @include fgcolor(tert);

    @include bdradi;
    @include clamp($width: null);

    &._ptag {
      font-size: rem(13px);
    }

    &._priv, &._base { @include fgcolor(secd); }
    &._priv { font-weight: 500; }
    &._base { font-style: italic; }

    @include hover { @include fgcolor(primary, 5); }

    &._hide {
      display: none;
    }

    &._icon {
      margin-left: -.25rem;
      margin-right: -.25rem;
      @include fgcolor(mute);
    }

    :global(svg) {
      margin-top: -0.125rem;
    }
  }
</style>
