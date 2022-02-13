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
  import type { VpTerm } from '$lib/vp_term'

  export let vpterm: VpTerm
  export let dname = 'combine'

  $: tag_hints = gen_hint(dname, vpterm)

  function gen_hint(dname: string, vpterm: VpTerm): string[] {
    if (dname == 'hanviet' || dname == 'tradsim') return []
    return vpterm.h_ptags(similar_tags(vpterm.ptag))
  }
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
  {#each vpterm.init.h_vals || [] as hint, idx (hint)}
    {#if idx == 0 || hint != vpterm.val.trim()}
      <button
        class="hint"
        class:_base={hint == vpterm.init.b_val}
        class:_priv={hint == vpterm.init.u_val}
        data-kbd={v_kbd[idx]}
        on:click={() => (vpterm.val = hint)}>{hint}</button>
    {/if}
  {/each}

  <div class="right">
    {#each tag_hints as tag, idx (tag)}
      {#if tag != vpterm.ptag}
        <button
          class="hint _ptag"
          class:_base={tag == vpterm.init.b_ptag}
          class:_priv={tag == vpterm.init.u_ptag}
          data-kbd={p_kbd[idx]}
          on:click={() => (vpterm.ptag = tag)}>{ptnames[tag]}</button>
      {/if}
    {/each}
  </div>
</div>

<style lang="scss">
  .hints {
    padding: 0 0.5rem;
    height: 2rem;

    @include flex($gap: 0.125rem);
    @include ftsize(sm);
  }

  .right {
    margin-left: auto;
    @include flex();
    max-width: 30%;
  }

  // prettier-ignore
  .hint {
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
  }
</style>
